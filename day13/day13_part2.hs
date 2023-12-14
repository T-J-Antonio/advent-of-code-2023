module Main where
import Control.Applicative ((<|>), Alternative, empty)
import Data.List (transpose, find)
import Data.Maybe (fromJust)

main :: IO ()
main = do
    content <- readFile "day13_input.txt"
    let rows = lines content
    let patternList = patterns rows
    let result = sum . map finalNumber $ patternList
    print result
    return ()

patterns :: [String] -> [[String]]
patterns = foldr (\line accum -> if line == "" then [] : accum else (line : head accum) : tail accum) [[]]

findReflection :: Alternative f => [String] -> f Int
findReflection = findReflectionAfter 1

findReflectionAfter :: Alternative f => Int -> [String] -> f Int
findReflectionAfter n rows
    | n == length (head rows) = empty
    | all (isReflection n) rows = pure n <|> findReflectionAfter (n + 1) rows
    | otherwise = findReflectionAfter (n + 1) rows

isReflection :: Int -> String -> Bool
isReflection n rows = let
    secondSide = take n . drop n $ rows
    offset = max 0 (n - length secondSide)
    firstSide = take (n - offset) . drop offset $ rows
    in firstSide == reverse secondSide

data Reflection = Rows Int | Columns Int deriving Eq

originalReflection :: [String] -> Reflection
originalReflection pattern = fromJust $ fmap Columns (findReflection pattern) <|> fmap Rows (findReflection (transpose pattern))

reflections :: [String] -> [Reflection]
reflections pattern = fmap Columns (findReflection pattern) ++ fmap Rows (findReflection (transpose pattern))

toInt :: Reflection -> Int
toInt (Rows x) = 100 * x
toInt (Columns x) = x

finalNumberIfValid :: [String] -> [String] -> Maybe Int
finalNumberIfValid original pattern = fmap toInt $ find (/= originalReflection original) $ reflections pattern

changeSmudge :: Char -> Char
changeSmudge '.' = '#'
changeSmudge '#' = '.'

newPattern :: (Int, Int) -> [String] -> [String]
newPattern (x, y) original = let
    rowToChange = original !! y
    in
    take y original ++
    [take x rowToChange ++ [changeSmudge (rowToChange !! x)] ++ drop (x + 1) rowToChange] ++
    drop (y + 1) original

finalNumber :: [String] -> Int
finalNumber original = let
    allPossibleChanges = [(x, y) | x <- [0..length (transpose original) - 1], y <- [0..length original - 1]]
    in
    fromJust $ fromJust $ find (/= Nothing) $ map (finalNumberIfValid original . flip newPattern original) allPossibleChanges