import db from "../db/db";
import { randomUUID } from "crypto";

let cachedNodes: any[] | null = null;
let cachedEdges: any[] | null = null;

function loadGraph() {
  if (!cachedNodes || !cachedEdges) {
    cachedNodes = db.prepare(`SELECT * FROM NAV_NODE`).all();
    cachedEdges = db.prepare(`SELECT * FROM NAV_EDGE`).all();
  }
}

function buildAdjacency(wheelchair: boolean) {
  loadGraph();

  const adj: Record<string, any[]> = {};

  cachedEdges!.forEach(edge => {
    if (wheelchair && edge.is_accessible === 0) return;

    if (!adj[edge.from_node_id]) adj[edge.from_node_id] = [];
    adj[edge.from_node_id].push(edge);

    if (edge.is_bidirectional === 1) {
      if (!adj[edge.to_node_id]) adj[edge.to_node_id] = [];
      adj[edge.to_node_id].push({
        ...edge,
        from_node_id: edge.to_node_id,
        to_node_id: edge.from_node_id
      });
    }
  });

  return adj;
}

function findDeptNode(deptId: string) {
  return db
    .prepare(`SELECT id FROM NAV_NODE WHERE department_id = ? LIMIT 1`)
    .get(deptId);
}

function getDeptName(deptId: string, lang: string) {
  const translation = db.prepare(`
    SELECT name 
    FROM DEPT_TRANSLATION
    WHERE department_id = ? AND language_id = ?
  `).get(deptId, lang);

  if (translation) return translation.name;

  const fallback = db.prepare(`
    SELECT name FROM DEPARTMENT WHERE id = ?
  `).get(deptId);

  return fallback?.name || "";
}

export default class NavigationService {

  static navigate(startNode: string, deptId: string, wheelchair: boolean, lang: string) {

    const destNode = findDeptNode(deptId);
    if (!destNode) throw new Error("Destination node not found");

    const adj = buildAdjacency(wheelchair);

    const dist: Record<string, number> = {};
    const prev: Record<string, string | null> = {};
    const visited = new Set<string>();

    cachedNodes!.forEach(n => {
      dist[n.id] = Infinity;
      prev[n.id] = null;
    });

    dist[startNode] = 0;

    while (true) {
      let closest: string | null = null;
      let best = Infinity;

      Object.keys(dist).forEach(node => {
        if (!visited.has(node) && dist[node] < best) {
          best = dist[node];
          closest = node;
        }
      });

      if (!closest) break;
      if (closest === destNode.id) break;

      visited.add(closest);

      const edges = adj[closest] || [];

      edges.forEach(e => {
        const alt = dist[closest!] + e.est_seconds;
        if (alt < dist[e.to_node_id]) {
          dist[e.to_node_id] = alt;
          prev[e.to_node_id] = closest;
        }
      });
    }

    const path: string[] = [];
    let current = destNode.id;

    while (current) {
      path.unshift(current);
      current = prev[current]!;
    }

    const steps: any[] = [];
    let totalDistance = 0;

    for (let i = 1; i < path.length; i++) {

      const edge = db.prepare(`
        SELECT * FROM NAV_EDGE 
        WHERE from_node_id=? AND to_node_id=?
        LIMIT 1
      `).get(path[i-1], path[i]);

      totalDistance += edge.distance_m;

      steps.push({
        node_id: path[i],
        instruction_text: `Move to next point`,
        voice_instruction: `Move to next point`,
        action_type: "STRAIGHT"
      });
    }

    const deptName = getDeptName(deptId, lang);

    steps.push({
      node_id: destNode.id,
      instruction_text: `Arrived at ${deptName}`,
      voice_instruction: `Arrived at ${deptName}`,
      action_type: "ARRIVED"
    });

    const sessionId = randomUUID();

    db.prepare(`
      INSERT INTO NAV_SESSION
      (id,start_node_id,dest_dept_id,status,total_steps,total_distance_m)
      VALUES (?,?,?,?,?,?)
    `).run(
      sessionId,
      startNode,
      deptId,
      "ACTIVE",
      steps.length,
      totalDistance
    );

    const insertStep = db.prepare(`
      INSERT INTO SESSION_STEP
      (id,session_id,node_id,step_order,instruction_text,voice_instruction,action_type)
      VALUES (?,?,?,?,?,?,?)
    `);

    steps.forEach((s, i) => {
      insertStep.run(
        randomUUID(),
        sessionId,
        s.node_id,
        i + 1,
        s.instruction_text,
        s.voice_instruction,
        s.action_type
      );
    });

    return {
      session_id: sessionId,
      total_steps: steps.length,
      total_distance_m: totalDistance,
      steps
    };
  }
}