module Main where
import Control.Applicative ((<|>))
import Data.List (transpose)

main :: IO ()
main = do
    content <- readFile "day13_input.txt"
    let rows = lines content
    let patternList = patterns rows
    let result = sum . map (\pattern -> sum $ findReflection pattern <|> fmap (* 100) (findReflection (transpose pattern)) ) $ patternList
    print result
    return ()

patterns :: [String] -> [[String]]
patterns = foldr (\line accum -> if line == "" then [] : accum else (line : head accum) : tail accum) [[]]

findReflection :: [String] -> Maybe Int
findReflection = findReflectionAfter 1

findReflectionAfter :: Int -> [String] -> Maybe Int
findReflectionAfter n rows
    | n == length (head rows) = Nothing
    | all (isReflection n) rows = Just n
    | otherwise = findReflectionAfter (n + 1) rows

isReflection :: Int -> String -> Bool
isReflection n rows = let
    secondSide = take n . drop n $ rows
    offset = max 0 (n - length secondSide)
    firstSide = take (n - offset) . drop offset $ rows
    in firstSide == reverse secondSide
