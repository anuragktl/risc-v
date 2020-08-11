// int main() {
//     register volatile unsigned int x3 asm("x3");
    
//     int count = 0;
//     while(1) {
// 		if(count < 10) {
// 			count++;
//     	} else {
//     		count = 0;
//     	}
//     	x3=count;
//     }
//     return 0;
// }

// int addition(int num1, int num2)
// {
//      int sum;
//      /* Arguments are used here*/
//      sum = num1+num2;

//      /* Function return type is integer so we are returning
//       * an integer value, the sum of the passed numbers.
//       */
//      return sum;
// }

// int main()
// {
//     register volatile unsigned int x3 asm("x3");
//      int var1, var2;
//      // printf("Enter number 1: ");
//      // scanf("%d",&var1);
//      // printf("Enter number 2: ");
//      // scanf("%d",&var2);
//      var1 = 5;
//      var2 = 9;


//      while (1) {

//          /* Calling the function here, the function return type
//           * is integer so we need an integer variable to hold the
//           * returned value of this function.
//           */
        
//         int res = addition(var1, var2);
//             // printf ("Output: %d", res);
//         var1 = var1 + 5;
//         var2 = var2 + 5;

//         x3 = res;
//     }

//      return 0;
// }

// #include <stdint.h>
int multiply (int num1, int num2) {
    int result = 0;
    for (int i = 0; i < num2; i++) {
        result = result + num1;
    }
    return result;
}
int recursive (int num1)
{
    register volatile unsigned int x4 asm("x4");
    if (num1 >= 1) {
        int recursive_multiply = multiply(num1, recursive(num1 - 1));
        // int result = 0;
        
        x4 = recursive_multiply;
        return recursive_multiply;  
    } else {
        return 1;
    }
    
    // return (num1 * (num1 - 1));
    

}

int main()
{
    register volatile unsigned int x3 asm("x3");

    int a = 0;
    while (1) {
        x3 = recursive(a);
        printf("value of %d is %d", a,x3);
        a = a + 1;
    }

    return 0;
}