#include <stdio.h>
#include < string.h>
using namespace std;
// a
int test(int a,int b){
    return a+b;
}
class Person {
public:
    // b
    Person(const char* name, int age) {
        this->name = strdup(name);
        this->age = age;
    }

    // c
    void introduce() {
        printf("Name: %s, Age: %d\n", name, age);
    }

    // d
    char* name;
    int age;
};

int main() {
    // e

    // f
    Person person1("Alice", 30);
    Person person2("Bob", 40);

    // g
    printf("Hello, World!\n");

    // h
    person1.introduce();
    person2.introduce();

    // i
    const char* str = "Hello";
    int num = 10;

    // j
    int a = 5;
    int b = 10;
    int sum = a + b;
    printf("Sum: %d\n", sum);

    // k
    bool condition = (a > b) && (sum > 15);
    printf("Condition: %s\n", condition ? "True" : "False");

    // l
    if (a > b) {
        printf("a is greater than b\n");
    } else if (a == b) {
        printf("a is equal to b\n");
    } else {
        printf("a is less than b\n");
    }

    // m
    for (int i = 0; i < 5; i++) {
        printf("Loop iteration: %d\n", i);
    }

    return 0;
}

