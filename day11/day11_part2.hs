module Main where
import Data.List (transpose, elemIndices)

main :: IO ()
main = do
    content <- readFile "day11_input.txt"
    let universe = lines content
    let r = rowsWithoutGalaxies universe
    let c = columnsWithoutGalaxies universe
    let result = sumDistances r c [] $ galaxiesList universe
    print result
    return ()

rowsWithoutGalaxies :: [String] -> [Int]
rowsWithoutGalaxies = map fst . filter (\(x, row) -> '#' `notElem` row) . zip [0..]

columnsWithoutGalaxies :: [String] -> [Int]
columnsWithoutGalaxies = rowsWithoutGalaxies . transpose

galaxiesInRow :: String -> [Int]
galaxiesInRow = elemIndices '#'

galaxiesList :: [String] -> [(Int, Int)]
galaxiesList = concatMap (\(y, row) -> map (, y) $ galaxiesInRow row) . zip [0..]

distance :: [Int] -> [Int] -> (Int, Int) -> (Int, Int) -> Int
distance r c (x1, y1) (x2, y2) = abs (x1 - x2) + abs (y1 - y2)
    + length (filter (\x -> x > x1 && x < x2 || x > x2 && x < x1) c) * 999999
    + length (filter (\y -> y > y1 && y < y2 || y > y2 && y < y1) r) * 999999

sumDistances :: [Int] -> [Int] -> [(Int, Int)] -> [(Int, Int)] -> Int
sumDistances _ _ _ [] = 0
sumDistances r c previous (galaxy : galaxies) =
    sum (map (distance r c galaxy) previous) + sumDistances r c (galaxy : previous) galaxies
