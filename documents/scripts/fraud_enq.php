<?/* require the user as the parameter */
if(intval($_GET['order_id'])) {

        /* soak in the passed variable or set our own */
        $format = strtolower($_GET['format']) == 'json' ? 'json' : 'xml'; //xml is the default
        $order_id = intval($_GET['order_id']); //no default

        /* connect to the db */
        $link = mysql_connect('localhost','fraud_score','11353568') or die('Cannot connect to the DB');
        mysql_select_db('excelclothingcom',$link) or die('Cannot select the
DB');

        /* grab the posts from the db */
        $query = "SELECT sales_flat_order.increment_id,
last_four_digits, sagepaysuite_transaction.avscv2,
sagepaysuite_transaction.address_result,
sagepaysuite_transaction.postcode_result,
sagepaysuite_transaction.cv2result,
threed_secure_status, thirdman_action,
thirdman_score FROM
sagepaysuite_transaction
LEFT OUTER JOIN sales_flat_order on sales_flat_order.entity_id = sagepaysuite_transaction.order_id
LEFT OUTER JOIN sagepayreporting_fraud ON sagepayreporting_fraud.order_id =
sagepaysuite_transaction.order_id
WHERE sales_flat_order.increment_id = $order_id limit 1";
        $result = mysql_query($query,$link) or die('Errant query:  '.$query);

        /* create one master array of the records */
        $posts = array();
        if(mysql_num_rows($result)) {
                while($post = mysql_fetch_assoc($result)) {
                        $posts = array('fraud_score'=>$post);
                }
        }

        /* output in necessary format */
        if($format == 'json') {
                header('Content-type: application/json');
                echo json_encode($posts);
        }
        else {
                header('Content-type: text/xml');
                echo '<fraud_scores>';
                foreach($posts as $index => $post) {
                        if(is_array($post)) {
                                foreach($post as $key => $value) {
                                        echo '<',$key,'>';
                                        if(is_array($value)) {
                                                foreach($value as $tag => $val) {
                                                        echo '<',$tag,'>',htmlentities($val),'</',$tag,'>';
                                                }
                                        }


                                        echo '</',$key,'>';
                                }
                        }
                }
                echo '</fraud_scores>';
        }

        /* disconnect from the db */
        @mysql_close($link);
}
?>

