# Домашнее задание к занятию "7.5. Основы golang"

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:
    ```
    package main
    
    import "fmt"
    
    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)
    
        output := input * 2
    
        fmt.Println(output)    
    }
    ```
 
1. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
    ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    ```
1. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

В виде решения ссылку на код или сам код. 

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания. 

## Решение

[Перевод метров в футы](./src/math/math.go)
```
package main

import "fmt"

func main() {
	fmt.Print("Enter a number: ")
	var input float64

	fmt.Scanf("%f", &input)

	output := input * 0.3048

	fmt.Println(output)
}
```

<p align="center">
  <img src="./img/GO.png">
</p>

[Деление](./src/division/division.go)

```
package main

import (
	"fmt"
)

func main() {

	for i := 1; i < 101; i++ {

		var t = i % 3
		if t == 0 {
			fmt.Println(i)
		}
	}
}
```

<p align="center">
  <img src="./img/GO_1.png">
</p>

[Минимальное число](./src/min)

```
package main

func Min(x []int) int {

	s := 0
	for i := range x {

		if s > x[i] {
			s = x[i]
		} else {
			if i == 0 {
				s = x[i]
			}
		}
	}
	return s
}
```

```
package main

import (
	"fmt"
	"testing"
)

func TestMin(t *testing.T) {
	var s int
	s = Min([]int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17})

	fmt.Println(s)

	if s == 0 {
		t.Error("Test", s)
	}
}
```

<p align="center">
  <img src="./img/GO_2.png">
</p>