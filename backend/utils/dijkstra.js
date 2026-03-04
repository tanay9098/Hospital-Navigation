/**
 * Dijkstra's shortest-path algorithm for the hospital navigation graph.
 *
 * graph format:
 *   {
 *     "GF-REC": [{ code: "GF-LOBBY", weight: 15, direction: "south" }, ...],
 *     ...
 *   }
 *
 * Returns:
 *   {
 *     path:     ["GF-REC", "GF-LOBBY", "GF-COR", ...],   // ordered node codes
 *     distance: 185,                                       // total cost (metres/secs)
 *     found:    true
 *   }
 */

class MinHeap {
  constructor() {
    this.heap = [];
  }

  push(node, priority) {
    this.heap.push({ node, priority });
    this._bubbleUp(this.heap.length - 1);
  }

  pop() {
    if (this.heap.length === 1) return this.heap.pop();
    const top = this.heap[0];
    this.heap[0] = this.heap.pop();
    this._sinkDown(0);
    return top;
  }

  isEmpty() {
    return this.heap.length === 0;
  }

  _bubbleUp(idx) {
    while (idx > 0) {
      const parent = Math.floor((idx - 1) / 2);
      if (this.heap[parent].priority <= this.heap[idx].priority) break;
      [this.heap[parent], this.heap[idx]] = [this.heap[idx], this.heap[parent]];
      idx = parent;
    }
  }

  _sinkDown(idx) {
    const n = this.heap.length;
    while (true) {
      let smallest = idx;
      const l = 2 * idx + 1;
      const r = 2 * idx + 2;
      if (l < n && this.heap[l].priority < this.heap[smallest].priority) smallest = l;
      if (r < n && this.heap[r].priority < this.heap[smallest].priority) smallest = r;
      if (smallest === idx) break;
      [this.heap[smallest], this.heap[idx]] = [this.heap[idx], this.heap[smallest]];
      idx = smallest;
    }
  }
}

/**
 * @param {Object} graph  Adjacency map: code → [{ code, weight, direction }]
 * @param {string} start  Source location code
 * @param {string} end    Destination location code
 * @param {boolean} accessibleOnly  Skip non-accessible elevator/stair nodes
 * @returns {{ path: string[], distance: number, found: boolean }}
 */
function dijkstra(graph, start, end, accessibleOnly = false) {
  if (start === end) {
    return { path: [start], distance: 0, found: true };
  }

  const distances = {};
  const previous = {};
  const visited = new Set();
  const pq = new MinHeap();

  for (const code of Object.keys(graph)) {
    distances[code] = Infinity;
    previous[code] = null;
  }

  distances[start] = 0;
  pq.push(start, 0);

  while (!pq.isEmpty()) {
    const { node: current } = pq.pop();

    if (current === end) break;
    if (visited.has(current)) continue;
    visited.add(current);

    const neighbours = graph[current] || [];
    for (const edge of neighbours) {
      if (visited.has(edge.code)) continue;
      // Skip inaccessible stairwells when user needs accessible route
      if (accessibleOnly && edge.isStairwell) continue;

      const newDist = distances[current] + edge.weight;
      if (newDist < distances[edge.code]) {
        distances[edge.code] = newDist;
        previous[edge.code] = { from: current, edge };
        pq.push(edge.code, newDist);
      }
    }
  }

  // Node not in graph at all, or unreachable
  if (distances[end] === undefined || distances[end] === Infinity) {
    return { path: [], distance: Infinity, found: false };
  }

  // Reconstruct path
  const path = [];
  let cur = end;
  while (cur !== null) {
    path.unshift(cur);
    cur = previous[cur] ? previous[cur].from : null;
  }

  return { path, distance: distances[end], found: true };
}

module.exports = dijkstra;
