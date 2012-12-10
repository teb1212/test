<?php
/*
Plugin Name: Custom Tag Cloud 
Author: Dionysios Papathanopoulos 
Description: Custom Tag Cloud.
Version:0.1
Text Domain:  Tagcloud
*/


	/* This class make all the necessary queries to the database in order to generate our custom tag cloud,
	 * Functions that require global wordpress informations
	 *	 * */
		function tag_admin() {
			require_once('admin_4.php');
			require('./wp-blog-header.php');
		}
	
		function tag_admin_actions() {
			add_options_page("Custom Tag Cloud", "Custom Tag Cloud", 'administrator', "tag_cloud_display_main", "tag_admin");
			
		}
		
		/* Fuction to get the terms from the database*/
		
		function get_term(){		
					mysql_connect(get_option('dbhost'), get_option('dbuser'), get_option('dbpwd')) or
						die("Could not connect: " . mysql_error());
							mysql_select_db(get_option('dbname'));
							$result = mysql_query("SELECT term_id,name FROM wp_terms where term_group = '1'");
						while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
							$term_id = $row[0];
					//		contract url of every tags,
							get_taxonomy_id($term_id);
							printf("%s ",'<a href="http://46.239.125.10/Machete/?tag='.$row[1].'"class="tag-link-6" title="'.$count.'" topics" style="font-size: 22pt;">'.$row[1].'</a>',"%s ");
								}
							mysql_free_result($result);
				}
		
		/*Function to get all terms id from  wp_term_taxonomy table. 
		 * Then take the term_id and count how many times id appears of the wp_term_relationships table
		 *  Use this Count variable to create the tag cloud.
		 * */
		function get_taxonomy_id($term_id){
			mysql_connect(get_option('dbhost'), get_option('dbuser'), get_option('dbpwd')) or
						die("Could not connect: " . mysql_error());
							mysql_select_db(get_option('dbname'));
					$result = mysql_query("SELECT term_taxonomy_id from wp_term_taxonomy where term_id =".$term_id);
					while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
						$term_taxonomy_id = $row[0];
					//	printf('test_term_id'.$term_taxonomy_id.'until here');
									$result_2 = mysql_query("SELECT Count(*) FROM wp_term_relationships where term_taxonomy_id =".$term_id);
											while ($row = mysql_fetch_array($result_2, MYSQL_NUM)) {
												$count = $row[0];
												//	printf('test_term_id'.$count.'until here');
														mysql_query("UPDATE wp_term_taxonomy SET count=".$count." WHERE term_taxonomy_id=".$term_taxonomy_id);
														mysql_free_result($result_2);
											}
	
						}
				mysql_free_result($result);
			}
		
		
// add the functions to wordpress theme 
		
		add_action('admin_menu', 'tag_admin_actions');	
		add_action('activate_test/custom_tags.php', 'bot_install');
		add_action('wp_footer', 'get_term');
		?>
			
