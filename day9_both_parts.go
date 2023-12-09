package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

func main() {
	bytes, err := os.ReadFile("day9_input.txt")
	if err != nil {
		return
	}
	lines := strings.Split(string(bytes), "\r\n")
	sumPart1 := int64(0)
	sumPart2 := int64(0)
	for _, line := range lines {
		numbersAsStr := strings.Split(line, " ")
		numbers := make([]int64, 0, len(numbersAsStr))
		for _, numberAsStr := range numbersAsStr {
			n, err := strconv.ParseInt(numberAsStr, 10, 64)
			if err != nil {
				return
			}
			numbers = append(numbers, n)
		}
		sumPart1 += newtonGregoryPredict(numbers, len(numbers))
		sumPart2 += newtonGregoryPredict(numbers, -1)
	}
	fmt.Printf("PART 1: %d\n", sumPart1)
	fmt.Printf("PART 2: %d\n", sumPart2)
}

func newtonGregoryPredict(numbers []int64, input int) int64 {
	coefs := make([]float64, 0, len(numbers))
	currentArray := make([]float64, 0, len(numbers))
	for _, n := range numbers {
		currentArray = append(currentArray, float64(n))
	}
	for i := 0; i < len(numbers); i++ {
		coefs = append(coefs, currentArray[0])
		newArray := make([]float64, 0, len(currentArray)-1)
		for j, n := range currentArray {
			j := j
			if j == 0 {
				continue
			}
			newArray = append(newArray, (n-currentArray[j-1])/float64(i+1))
		}
		currentArray = newArray
	}
	prediction := float64(0)
	for i, c := range coefs {
		i := i
		term := c
		for j := 0; j < i; j++ {
			j := j
			term *= float64(input - i + j + 1)
		}
		prediction += term
	}
	return int64(math.Round(prediction))
}
