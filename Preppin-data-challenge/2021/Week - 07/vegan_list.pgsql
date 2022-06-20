/*Preppin Data Challenge: Vegan Shopping List (Week 7)
- Input the data
- Prepare the keyword data
  * Add an 'E' in front of every E number.
  * Stack Animal Ingredients and E Numbers on top of each other.
  * Get every ingredient and E number onto separate rows.
- Append the keywords onto the product list.
- Check whether each product contains any non-vegan ingredients.
- Prepare a final shopping list of vegan products.
  * Aggregate the products into vegan and non-vegan.
  * Filter out the non-vegan products.
- Prepare a list explaining why the other products aren't vegan.
  * Keep only non-vegan products.
  * Duplicate the keyword field.
  * Rows to columns pivot the keywords using the duplicate as a header.
  * Write a calculation to concatenate all the keywords into a single comma-separated list for each product, e.g. "whey, milk, egg".
- Output the data.
DROP TABLE IF EXISTS shopping_list;
CREATE TABLE shopping_list ( Product varchar(1500),
						     Description varchar(2000),
						     Ingredients varchar(2000));
*/

SELECT product,
       description,
       REGEXP_MATCHES(ingredients,
					'Milk|Whey|Honey|Egg|Lactose|Collagen|Elastin|Keratin|Gelatine|
					 Gelatin|Pepsin|Isinglass|Shellac|Lard|Aspic|Beeswax') AS Contains_
FROM shopping_list;


