import Data.Char (isDigit)
import Control.Applicative ( Alternative((<|>)) )
import Data.List (nub)
main :: IO ()
main = do
    content <- readFile "day5_input.txt"
    let rows = lines content
    let maps = map parseMap $ separatedMaps $ filter (not . null) $ tail rows
    let seeds = seedsToRanges $ map (read :: String -> Int) $ words $ dropWhile (not . isDigit) $ head rows
    let result = minimum $ map (`seedToLocation` maps) seeds
    print result
    return ()

seedsToRanges :: [Int] -> [Int]
seedsToRanges [] = []
seedsToRanges (x1 : x2 : xs) = [x1 .. x1 + x2 - 1] ++ seedsToRanges xs

separatedMaps :: [String] -> [[String]]
separatedMaps = filter (not . null) . foldr (\line list ->
    if isDigit $ head line then (line : head list) : tail list else [] : list) [[]]

type PartialMap = Int -> Maybe Int
type Map = Int -> Int

parseSingleLine :: String -> PartialMap
parseSingleLine str = let
    destinationRangeStart = (read :: String -> Int) . head . words $ str
    sourceRangeStart = (read :: String -> Int) . (!! 1) . words $ str
    rangeLength = (read :: String -> Int) . (!! 2) . words $ str
    in
    \x -> if x >= sourceRangeStart && x < sourceRangeStart + rangeLength
        then Just $ x - sourceRangeStart + destinationRangeStart
        else Nothing

parseMap :: [String] -> Map
parseMap = turnTotal . foldr ((\partialMap map x -> partialMap x <|> map x) . parseSingleLine) Just

turnTotal :: PartialMap -> Map
turnTotal f x = sum $ f x

seedToLocation :: Int -> [Map] -> Int
seedToLocation = foldl (\x f -> f x)