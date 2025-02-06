#include<stdio.h>

/* This
   is
   a
   bubble
   sort
*/
int main(){
    int n;
    // single line comment
    scanf("%d", &n);

    int array[n];
    /* Sample Multiline Comment
    Line 1
    Line 2
    ….
    …
    */
    for(int i=0; i<n; i++)
        scanf("%d", &array[i]);

    for(int i=0; i<n; i++){
        for(int j=0; j<n-i; j++){
            if(array[j+1]<array[j]){
                int temp;
                temp=array[j+1];
                array[j+1]=array[j];
                array[j]=temp;
            }
        }
    }
    for(int i=0; i<n; i++)
        printf("%d ", array[i]);
    return 0;
}
