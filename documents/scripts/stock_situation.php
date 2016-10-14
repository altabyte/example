<?

/* connect to the db */
$link = mysql_connect('localhost', 'fraud_score', '11353568') or die('Cannot connect to the DB');
mysql_select_db('excelclothingcom', $link) or die('Cannot select the DB');

/* grab the posts from the db */
$query = "SELECT sku, cataloginventory_stock_item.qty
FROM  `catalog_product_entity` 
INNER JOIN cataloginventory_stock_item ON cataloginventory_stock_item.product_id = catalog_product_entity.entity_id
WHERE catalog_product_entity.type_id =  'simple'";
$result = mysql_query($query, $link) or die('Errant query:  ' . $query);

/* create one master array of the records */
//$posts = array();
//if (mysql_num_rows($result)) {
//    while ($post = mysql_fetch_assoc($result)) {
//        $posts = array('fraud_score' => $post);
//    }
//}
$config['table_name'] = "stock_qty";
$xml          = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
$root_element = "stock_qtys";
$xml         .= "<$root_element>";


if(mysql_num_rows($result)>0)
{
   while($result_array = mysql_fetch_assoc($result))
   {
      $xml .= "<".$config['table_name'].">";
 
      //loop through each key,value pair in row
      foreach($result_array as $key => $value)
      {
         //$key holds the table column name
         $xml .= "<$key>";
 
         //embed the SQL data in a CDATA element to avoid XML entity issues
         $xml .= "$value"; 
 
         //and close the element
         $xml .= "</$key>";
      }
 
      $xml.="</".$config['table_name'].">";
   }
}

//close the root element
$xml .= "</$root_element>";
 
//send the xml header to the browser
header ("Content-Type:text/xml"); 
$dom = new DOMDocument;
$dom->preserveWhiteSpace = FALSE;
$dom->loadXML($xml);
$dom->formatOutput = TRUE;
echo $dom->saveXml();
 
//output the XML data
//echo $xml;
/* disconnect from the db */
@mysql_close($link);
?>
