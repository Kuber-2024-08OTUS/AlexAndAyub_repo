package main

import (
	"fmt"
	"os"
	"strings"
)

func get_env() map[string]string {
	//Получение списка переменных окружения в виде карты

	envs := os.Environ()
	envcMap := make(map[string]string)

	for _, envVar := range envs {
		value := strings.Split(envVar, "=")
		envcMap[value[0]] = value[1]
	}

	return envcMap
}

func main() {
	t := get_env()
	fmt.Println(t)
}
