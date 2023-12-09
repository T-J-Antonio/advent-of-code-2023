module Main where

main :: IO ()
main = do
    content <- readFile "day8_input.txt"
    let rows = lines content
    let directions = cycle $ readDirections (head rows)
    let nodes = map readNode (drop 2 rows)
    let start = lookupNode nodes "AAA"
    let result = numberOfSteps directions nodes start
    print result
    return ()

data Direction = L | R deriving (Read, Eq)

readDirections :: String -> [Direction]
readDirections = map (read . (: []))

data Node = Node {
    name :: String,
    travel :: Direction -> String
}

readNode :: String -> Node
readNode str = let
    source = take 3 str
    dstL = take 3 . drop 7 $ str
    dstR = take 3 . drop 12 $ str
    in
    Node source (\dir -> if dir == L then dstL else dstR)

lookupNode :: [Node] -> String -> Node
lookupNode list str = head $ filter (\n -> name n == str) list

travelToNode :: Direction -> [Node] -> Node -> Node
travelToNode dir nodes node = lookupNode nodes $ travel node dir

numberOfSteps :: [Direction] -> [Node] -> Node -> Int
numberOfSteps (d : ds) nodes startNode = let
    newNode = travelToNode d nodes startNode
    in
    if name newNode == "ZZZ" then 1 else 1 + numberOfSteps ds nodes newNode