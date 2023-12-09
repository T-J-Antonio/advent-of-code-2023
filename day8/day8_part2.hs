module Main where
import qualified Data.Map as Map
import Data.Maybe ( fromJust )
import Data.List ( findIndices, find )

main :: IO ()
main = do
    content <- readFile "day8_input.txt"
    let rows = lines content
    let completeMap = Map.unions $ map readNode (drop 2 rows)
    let start = map (take 3) $ filter ((== 'A') . (!! 2)) (drop 2 rows)
    let directions = cycle $ head rows
    let loop = map (steps directions completeMap) start
    let loopSize = length $ head rows
    let pointsOfStartAndEnd = map (findLoop loopSize) loop
    let zsBeforeStarting = findZs . map (\(n, steps) -> take n steps) $ zip (map fst pointsOfStartAndEnd) loop
    let zsInLoop = findZs . map (\((i, j), steps) -> drop i . take j $ steps) $ zip pointsOfStartAndEnd loop
    checkPrematureMatch pointsOfStartAndEnd zsBeforeStarting zsInLoop
    let actualZsInLoop = zipWith (\(i, _) zs -> map (+(i+1)) zs) pointsOfStartAndEnd zsInLoop
    let result = minimum $ map (foldr1 lcm) $ sequence actualZsInLoop
    print result
    return ()

steps :: String -> Map.Map String String -> String -> [String]
steps (d : ds) completeMap startNode = let
    newNode = completeMap Map.! (d : startNode)
    in
    newNode : steps ds completeMap newNode

readNode :: String -> Map.Map String String
readNode str = let
    source = take 3 str
    dstL = take 3 . drop 7 $ str
    dstR = take 3 . drop 12 $ str
    in
    Map.fromList [('L' : source, dstL), ('R' : source, dstR)]

findLoop :: Int -> [String] -> (Int, Int)
findLoop loopSize steps = findLoopWithMap loopSize steps Map.empty 0

findLoopWithMap :: Int -> [String] -> Map.Map String [Int] -> Int -> (Int, Int)
findLoopWithMap loopSize (step : steps) currentMap currentIter = let
    found = find (\x -> (x - currentIter) `mod` loopSize == 0) (Map.findWithDefault [] step currentMap)
    in case found of
        Just n -> (n + 1, currentIter + 1)
        Nothing -> findLoopWithMap loopSize steps (Map.insertWith (++) step [currentIter] currentMap) (currentIter + 1)

findZs :: [[String]] -> [[Int]]
findZs = map (findIndices ((== 'Z') . last))

-- This last part checks whether a match is produced before all ghosts enter the loop.
-- Of course, this doesn't happen, but I wanted every case to be covered.

checkPrematureMatch :: [(Int, Int)] -> [[Int]] -> [[Int]] -> IO ()
checkPrematureMatch pointsOfStartAndEnd zsBeforeStarting zsInLoop = do
    let firstZsList = map (take (maximum (map fst pointsOfStartAndEnd))) $ zipWith3 totalZs zsBeforeStarting zsInLoop pointsOfStartAndEnd
    let prematureMatch = firstMatch firstZsList
    if prematureMatch /= Nothing then print (fromJust $ prematureMatch) else pure ()

loopingZs :: Int -> [Int] -> [Int]
loopingZs loopSize zs = concatMap (\m -> map (\n -> n + m * loopSize) zs) [0..]

totalZs :: [Int] -> [Int] -> (Int, Int) -> [Int]
totalZs zsBefore zsInLoop (loopStart, loopEnd) = zsBefore ++ loopingZs (loopEnd - loopStart) (map (+ (loopStart + 1)) zsInLoop)

matchesZ :: Int -> [Int] -> Bool
matchesZ _ [] = False
matchesZ n (z : zs) = z <= n && (n == z || matchesZ n zs)

firstMatch :: [[Int]] -> Maybe Int
firstMatch (zs : otherZs) = find (\z -> all (matchesZ z) otherZs) zs