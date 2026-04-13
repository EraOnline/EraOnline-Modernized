using EraOnline.Client.CLI.Session;

namespace EraOnline.Client.CLI.Navigation;

/// <summary>
/// A* pathfinding on a 100x100 tile grid.
/// Uses the map's blocked tile array from world knowledge.
/// </summary>
public static class Pathfinder
{
    /// <summary>
    /// Find a path from (startX, startY) to (goalX, goalY) on the given map.
    /// Returns a list of (x, y) positions to walk through (excluding start), or null if no path.
    /// </summary>
    public static List<(int x, int y)>? FindPath(MapKnowledge map, int startX, int startY, int goalX, int goalY)
    {
        if (map.BlockedTiles == null) return null;
        if (startX == goalX && startY == goalY) return new List<(int, int)>();

        // A* with 4-directional movement (matching Era Online's movement model)
        var open = new PriorityQueue<(int x, int y), int>();
        var cameFrom = new Dictionary<(int, int), (int, int)>();
        var gScore = new Dictionary<(int, int), int>();

        var start = (startX, startY);
        var goal = (goalX, goalY);

        gScore[start] = 0;
        open.Enqueue(start, Heuristic(start, goal));

        var directions = new (int dx, int dy)[] { (0, -1), (0, 1), (-1, 0), (1, 0) }; // N, S, W, E

        while (open.Count > 0)
        {
            var current = open.Dequeue();

            if (current == goal)
            {
                // Reconstruct path
                var path = new List<(int, int)>();
                var node = current;
                while (cameFrom.ContainsKey(node))
                {
                    path.Add(node);
                    node = cameFrom[node];
                }
                path.Reverse();
                return path;
            }

            var currentG = gScore[current];

            foreach (var (dx, dy) in directions)
            {
                var nx = current.x + dx;
                var ny = current.y + dy;

                if (nx < 1 || nx > 100 || ny < 1 || ny > 100) continue;

                // Check blocked
                var idx = (ny - 1) * 100 + (nx - 1);
                if (map.BlockedTiles[idx] != 0) continue;

                var neighbor = (nx, ny);
                var tentativeG = currentG + 1;

                if (!gScore.TryGetValue(neighbor, out var bestG) || tentativeG < bestG)
                {
                    gScore[neighbor] = tentativeG;
                    cameFrom[neighbor] = current;
                    var f = tentativeG + Heuristic(neighbor, goal);
                    open.Enqueue(neighbor, f);
                }
            }
        }

        return null; // No path found
    }

    /// <summary>
    /// Convert a path of (x,y) positions into a list of Direction values (1=N, 2=E, 3=S, 4=W).
    /// </summary>
    public static List<int> PathToDirections(List<(int x, int y)> path, int startX, int startY)
    {
        var directions = new List<int>();
        int cx = startX, cy = startY;

        foreach (var (nx, ny) in path)
        {
            if (ny < cy) directions.Add(1);      // North
            else if (nx > cx) directions.Add(2);  // East
            else if (ny > cy) directions.Add(3);  // South
            else if (nx < cx) directions.Add(4);  // West
            cx = nx;
            cy = ny;
        }

        return directions;
    }

    private static int Heuristic((int x, int y) a, (int x, int y) b)
    {
        return Math.Abs(a.x - b.x) + Math.Abs(a.y - b.y); // Manhattan distance
    }
}
