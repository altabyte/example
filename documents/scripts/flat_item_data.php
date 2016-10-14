<?

/* connect to the db */
$link = mysql_connect('localhost', 'fraud_score', '11353568') or die('Cannot connect to the DB');
mysql_select_db('excelclothingcom', $link) or die('Cannot select the DB');

$sku = $_GET['sku'];

/* grab the posts from the db */
$query = "SELECT  sku, color_value, size_value, price, name, harmon_code.value as harmon_code, country_code.value as country_code
FROM catalog_product_flat_1 left outer join catalog_product_entity_varchar harmon_code on (harmon_code.entity_id = catalog_product_flat_1.entity_id and harmon_code.attribute_id = 1504)
 left outer join catalog_product_entity_varchar country_code on (country_code.entity_id = catalog_product_flat_1.entity_id and country_code.attribute_id = 1503)
where sku = $sku;";	
$result = mysql_query($query, $link) or die('Errant query:  ' . $query);

$config['table_name'] = "item";
$xml          = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
$root_element = "items";
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
