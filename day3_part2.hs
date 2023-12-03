module Main where
import Prelude
import Data.Char (isDigit)
import Control.Monad (guard)

main :: IO ()
main = do
    content <- readFile "day3_input.txt"
    let rows = lines content
    print (sumOfPartNumbers rows)
    return ()

sumOfPartNumbers :: [String] -> Int
sumOfPartNumbers lines =
    sumOfFirstRow (head lines) (lines !! 1)
    + sumOfLastRow (lines !! (length lines - 2)) (last lines)
    + sum (zipWith3 sumOfIntermediateRow lines (tail lines) (tail $ tail lines))

sumOfFirstRow :: String -> String -> Int
sumOfFirstRow curr next =
    sum $
    map (sum . gearRatio "" curr next) $
    indexesSuchThat (== '*') curr

sumOfLastRow :: String -> String -> Int
sumOfLastRow prev curr =
    sum $
    map (sum . gearRatio prev curr "") $
    indexesSuchThat (== '*') curr

sumOfIntermediateRow :: String -> String -> String -> Int
sumOfIntermediateRow prev curr next =
    sum $
    map (sum . gearRatio prev curr next) $
    indexesSuchThat (== '*') curr

indexesSuchThat :: (Char -> Bool) -> String -> [Int]
indexesSuchThat f str = foldr (\n list -> if f $ str !! n then n : list else list) [] [0..(length str - 1)]

consecutives :: [Int] -> [[Int]]
consecutives = foldl (\list n ->
    if null list then [[n]] else
        (if (n-1) `elem` last list then init list ++ [last list ++ [n]] else list ++ [[n]])
        ) []

gearRatio :: String -> String -> String -> Int -> Maybe Int
gearRatio prev curr next index = do
    let partNumbers = (map (, prev) . consecutives . indexesSuchThat isDigit $ prev) ++ (map (, curr) . consecutives . indexesSuchThat isDigit $ curr) ++ (map (, next) . consecutives . indexesSuchThat isDigit $ next)
    let adjacentPartNumbers = filter ((\list -> index `elem` list || index - 1 `elem` list || index + 1 `elem` list) . fst) partNumbers
    guard ((== 2) . length $ adjacentPartNumbers)
    return (product (map (\(indexes, str) -> (read :: String -> Int) $ map (str !!) indexes) adjacentPartNumbers))