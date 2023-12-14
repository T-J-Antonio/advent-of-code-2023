package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	bytes, err := os.ReadFile("day14_input.txt")
	if err != nil {
		return
	}
	rows := strings.Split(string(bytes), "\r\n")
	columns := make([]string, len(rows[0]))
	for _, row := range rows {
		for i, c := range row {
			i := i
			columns[i] = columns[i] + string(c)
		}
	}
	sum := 0
	for _, column := range columns {
		newColumn := rollVertically(column)
		for i, c := range newColumn {
			if c == 'O' {
				sum = sum + len(newColumn) - i
			}
		}
	}
	fmt.Println(sum)
}

func rollVertically(column string) string {
	res := make([]rune, len(column))
	for i, c := range column {
		i := i
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
