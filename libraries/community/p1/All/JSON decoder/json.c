/**
 * @file json.c
 * @brief Convert Json data to values
 * @author Michael Burmeister
 * @date December 29, 2018
 * @version 1.0
 * 
*/

#include "json.h"
#include "simpletools.h"

short json_getItem(void);

char ItemName[32];
char ItemValue[64];
char ItemPath[15][32];
short ItemLevel;
short ItemPointer;
short ItemArray;
char ItemT[64];
char *ItemData;
char ItemE[64];
char Quote = '\"';
char jStart = '{';
char jEnd = '}';

void json_init(char *d)
{
  ItemLevel = 0;
  ItemPointer = 0;
  ItemArray = 0;
  ItemE[0] = 0;
  ItemT[0] = 0;
  ItemData = d;
}  

char *json_find(char *e)
{
  while (json_getItem() > 0)
  {
    if (strcmp(e, ItemName) == 0)
      return ItemValue;
  }
  return "N/A";
}

short json_getItem()
{
  int i = 0;
  int Parse = 1;
  while (Parse)
  {
    if (ItemPointer++ >= strlen(ItemData)-1)
      return 0;
    switch (ItemData[ItemPointer])
    {
      case '{':
        if (ItemE[0] > 0)
          strcpy(ItemPath[ItemLevel++], ItemE);
        break;
      case '\"':
        break;
      case ':':
        strcpy(ItemE, ItemT);
        ItemName[0] = 0;
        for (i=0;i<ItemLevel;i++)
        {
          strcat(ItemName, ItemPath[i]);
          strcat(ItemName, ".");
        }
        strcat(ItemName, ItemE);
        i = 0;
        break;
      case '}':
        ItemLevel--;
        strcpy(ItemValue, ItemT);
        i = 0;
        Parse = 0;
        break;
      case ',':
        if (i == 0)
        {
          if (ItemArray > 0)
          {
            ItemE[0] = 0;
            ItemLevel++;
          }
          break;
        }
        strcpy(ItemValue, ItemT);
        i = 0;
        Parse = 0;
        break;
      case '[':
        ItemArray++;
        break;
      case ']':
        ItemArray--;
        break;                      
      default:
        ItemT[i++] = ItemData[ItemPointer];
        ItemT[i] = 0;
        break;
    }
  }
  return 1;    
}

void json_putStr(char *item, char *value)
{
  if (ItemPointer == 0)
    ItemData[ItemPointer++] = jStart;
  else
    ItemData[ItemPointer++] = ',';
  
  ItemData[ItemPointer++] = Quote;
  strcpy(&ItemData[ItemPointer], item);
  ItemPointer += strlen(item);
  ItemData[ItemPointer++] = Quote;
  ItemData[ItemPointer++] = ':';
  ItemData[ItemPointer++] = Quote;
  strcpy(&ItemData[ItemPointer], value);
  ItemPointer += strlen(value);
  ItemData[ItemPointer++] = Quote;
  ItemData[ItemPointer] = jEnd;
}

void json_putDec(char *item, char *value)
{
  if (ItemPointer == 0)
    ItemData[ItemPointer++] = jStart;
  else
    ItemData[ItemPointer++] = ',';
  
  ItemData[ItemPointer++] = Quote;
  strcpy(&ItemData[ItemPointer], item);
  ItemPointer += strlen(item);
  ItemData[ItemPointer++] = Quote;
  ItemData[ItemPointer++] = ':';
  strcpy(&ItemData[ItemPointer], value);
  ItemPointer += strlen(value);
  ItemData[ItemPointer] = jEnd;
}