/**
 * @brief Convert Json data to values
 * @author Michael Burmeister
 * @date December 29, 2018
 * @version 1.0
 * 
*/
#include "json.h"
#include "simpletools.h"

char data[] = "{\"coord\":{\"lon\":-87.38,\"lat\":44.83}}";


int main()
{
  char *x;
  
  json_init(data);

  x = json_find("coord.lat");
  
  print(x);
  while(1)
  {
    // Add main loop code here.
    
  }  
}
