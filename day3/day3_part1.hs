module Main where
import Prelude
import Data.Char (isDigit)

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
    map ((read :: String -> Int) . map (curr !!)) $
    filter (isPartNumber "" curr next) $
    consecutives $
    indexesSuchThat isDigit curr

sumOfLastRow :: String -> String -> Int
sumOfLastRow prev curr =
    sum $
    map ((read :: String -> Int) . map (curr !!)) $
    filter (isPartNumber prev curr "") $
    consecutives $
    indexesSuchThat isDigit curr

sumOfIntermediateRow :: String -> String -> String -> Int
sumOfIntermediateRow prev curr next =
    sum $
    map ((read :: String -> Int) . map (curr !!)) $
    filter (isPartNumber prev curr next) $
    consecutives $
    indexesSuchThat isDigit curr

indexesSuchThat :: (Char -> Bool) -> String -> [Int]
indexesSuchThat f str = foldr (\n list -> if f $ str !! n then n : list else list) [] [0..(length str - 1)]

isPartNumber :: String -> String -> String -> [Int] -> Bool
isPartNumber previous current next indexes = any (\n ->
    n `elem` indexesSuchThat isSymbol previous || n `elem` indexesSuchThat isSymbol current || n `elem` indexesSuchThat isSymbol next)
    (indexes ++ [head indexes - 1, last indexes + 1])

isSymbol :: Char -> Bool
isSymbol c = not (isDigit c || c == '.')

consecutives :: [Int] -> [[Int]]
consecutives = foldl (\list n ->
    if null list then [[n]] else
        (if (n-1) `elem` last list then init list ++ [last list ++ [n]] else list ++ [[n]])
        ) []