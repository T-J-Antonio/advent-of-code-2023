module Main where
import Data.List (transpose, elemIndices)

main :: IO ()
main = do
    content <- readFile "day11_input.txt"
    let universe = expandUniverse $ lines content
    let result = sumDistances [] $ galaxiesList universe
    print result
    return ()

expandRow :: String -> [String]
expandRow str
    | '#' `elem` str = [str]
    | otherwise = [str, str]

expandUniverse :: [String] -> [String]
expandUniverse = transpose . concatMap expandRow . transpose . concatMap expandRow

galaxiesInRow :: String -> [Int]
galaxiesInRow = elemIndices '#'

galaxiesList :: [String] -> [(Int, Int)]
galaxiesList = concatMap (\(y, row) -> map (, y) $ galaxiesInRow row) . zip [0..]

distance :: (Int, Int) -> (Int, Int) -> Int
distance (x1, y1) (x2, y2) = abs (x1 - x2) + abs (y1 - y2)

sumDistances :: [(Int, Int)] -> [(Int, Int)] -> Int
sumDistances _ [] = 0
sumDistances previous (galaxy : galaxies) = sum (map (distance galaxy) previous) + sumDistances (galaxy : previous) galaxies
