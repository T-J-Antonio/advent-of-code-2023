package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	day14_part1()
	day14_part2()
}

func day14_part1() {
	bytes, err := os.ReadFile("day14_input.txt")
	if err != nil {
		return
	}
	rows := strings.Split(string(bytes), "\r\n")
	columns := make([]string, len(rows[0]))
	for _, row := range rows {
		for i, c := range row {
			columns[i] = columns[i] + string(c)
		}
	}
	sum := 0
	for _, column := range columns {
		newColumn := rollNegatively(column)
		for i, c := range newColumn {
			if c == 'O' {
				sum = sum + len(newColumn) - i
			}
		}
	}
	fmt.Println(sum)
}

// for North and West
func rollNegatively(line string) string {
	res := make([]rune, len(line))
	for i, c := range line {
		if c == '.' || c == '#' {
			res[i] = c
			continue
		}
		j := i
		for j > 0 && res[j-1] == '.' {
			j--
		}
		res[i] = '.'
		res[j] = 'O'
	}
	return string(res)
}

func day14_part2() {
	bytes, err := os.ReadFile("day14_input.txt")
	if err != nil {
		return
	}
	rows := strings.Split(string(bytes), "\r\n")
	iterations := make([][]string, 0)
	for repetition(iterations, rows) == -1 {
		iterations = append(iterations, rows)
		rows = cycle(rows)
	}
	repetitionSize := len(iterations) - repetition(iterations, rows)
	for i := 0; i < (1000000000-len(iterations))%repetitionSize; i++ {
		rows = cycle(rows)
	}
	columns := make([]string, len(rows[0]))
	for _, row := range rows {
		for i, c := range row {
			columns[i] = columns[i] + string(c)
		}
	}
	sum := 0
	for _, column := range columns {
		for i, c := range column {
			if c == 'O' {
				sum = sum + len(column) - i
			}
		}
	}
	fmt.Println(sum)
}

func cycle(rows []string) []string {
	// North
	columns := make([]string, len(rows[0]))
	for _, row := range rows {
		for i, c := range row {
			columns[i] = columns[i] + string(c)
		}
	}
	for i, column := range columns {
		columns[i] = rollNegatively(column)
	}
	// West
	rows = make([]string, len(columns[0]))
	for _, column := range columns {
		for i, c := range column {
			rows[i] = rows[i] + string(c)
		}
	}
	for i, row := range rows {
		rows[i] = rollNegatively(row)
	}
	// South
	columns = make([]string, len(rows[0]))
	for _, row := range rows {
		for i, c := range row {
			columns[i] = columns[i] + string(c)
		}
	}
	for i, column := range columns {
		columns[i] = rollPositively(column)
	}
	// East
	rows = make([]string, len(columns[0]))
	for _, column := range columns {
		for i, c := range column {
			rows[i] = rows[i] + string(c)
		}
	}
	for i, row := range rows {
		rows[i] = rollPositively(row)
	}
	return rows
}

func reverse(line string) string {
	chars := []rune(line)
	total := len(line) - 1
	newChars := make([]rune, len(chars))
	for i, c := range chars {
		newChars[total-i] = c
	}
	return string(newChars)
}

// for South and East
func rollPositively(line string) string {
	line = reverse(line)
	line = rollNegatively(line)
	return reverse(line)
}

func repetition(iterations [][]string, rows []string) int {
	for i, iteration := range iterations {
		foundDifference := false
		for j, row := range iteration {
			if row != rows[j] {
				foundDifference = true
			}
		}
		if !foundDifference {
			return i
		}
	}
	return -1
}
