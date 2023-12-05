import Data.Char (isDigit)
import Control.Applicative ( Alternative((<|>)) )
import System.IO.Memoize (eagerlyOnce)
import Debug.Trace

main :: IO ()
main = do
    readOnce <- eagerlyOnce $ readFile "day5_input.txt"
    content <- readOnce
    let (seedRow : mapRows) = lines content
    let maps = separatedMaps $ filter (not . null) mapRows
    let minOutputs = parseMinimums $ last maps
    let inverseMaps = reverse $ map parseInverseMap maps
    let minInputs = minimumInputs inverseMaps minOutputs
    let seeds = seedsToRanges $ map (read :: String -> Int) $ words $ dropWhile (not . isDigit) seedRow
    let actualSeeds = 0 : filter (\n -> any (\(start, offset) -> n >= start && n < start + offset) seeds) minInputs

    let seedToLocation = collapseMaps $ map parseMap maps
    let result = minimum $ map seedToLocation actualSeeds
    print result
    return ()

seedsToRanges :: [Int] -> [(Int, Int)]
seedsToRanges [] = []
seedsToRanges (x1 : x2 : xs) = (x1, x2) : seedsToRanges xs

separatedMaps :: [String] -> [[String]]
separatedMaps = filter (not . null) . foldr (\line list ->
    if isDigit $ head line then (line : head list) : tail list else [] : list) [[]]

type PartialMap = Int -> Maybe Int
type Map = Int -> Int

mapFromString :: String -> PartialMap
mapFromString str = let
    destinationRangeStart = (read :: String -> Int) . head . words $ str
    sourceRangeStart = (read :: String -> Int) . (!! 1) . words $ str
    rangeLength = (read :: String -> Int) . (!! 2) . words $ str
    in
    \x -> if x >= sourceRangeStart && x < sourceRangeStart + rangeLength
        then Just $ x - sourceRangeStart + destinationRangeStart
        else Nothing

parseMap :: [String] -> Map
parseMap = turnTotal . foldr ((\partial1 partial2 x -> partial1 x <|> partial2 x) . mapFromString) Just

turnTotal :: PartialMap -> Map
turnTotal f x = sum $ f x

collapseMaps :: [Map] -> Map
collapseMaps = foldr (flip (.)) id

type InverseMap = Int -> [Int]

inverseMapFromString :: String -> InverseMap
inverseMapFromString str = let
    destinationRangeStart = (read :: String -> Int) . head . words $ str
    sourceRangeStart = (read :: String -> Int) . (!! 1) . words $ str
    rangeLength = (read :: String -> Int) . (!! 2) . words $ str
    in
    \y -> if y >= destinationRangeStart && y < destinationRangeStart + rangeLength
        then [y - destinationRangeStart + sourceRangeStart]
        else []

parseInverseMap :: [String] -> InverseMap
parseInverseMap = foldr ((\partialMap map x -> partialMap x ++ map x) . inverseMapFromString) (: [])

parseMinimums :: [String] -> [Int]
parseMinimums = map (read . head . words)

minimumInputs :: [InverseMap] -> [Int] -> [Int]
minimumInputs [] inputs = inputs
minimumInputs (m : ms) outputs = minimumInputs ms (concatMap m outputs)