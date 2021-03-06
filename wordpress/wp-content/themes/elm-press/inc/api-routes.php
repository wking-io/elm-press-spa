<?php
/**
 * Setup for API Routes
 *
 * @package elm-press
 */

/**
 * Register custom REST API routes.
 */
add_action( 'rest_api_init', function () {
	// Define API endpoint arguments.
	$slug_arg          = array(
		'validate_callback' => function ( $param, $request, $key ) {
			return( is_string( $param ) );
		},
	);
	$post_slug_arg     = array_merge( $slug_arg, array( 'description' => 'String representing a valid WordPress post slug' ) );
	$page_slug_arg     = array_merge( $slug_arg, array( 'description' => 'String representing a valid WordPress page slug' ) );
	$per_page_arg      = array(
		'validate_callback' => function ( $param, $request, $key ) {
			return( is_integer( $param ) );
		},
	);
	$post_per_page_arg = array_merge( $per_page_arg, array( 'description' => 'Int representing the number of posts to get per page for pagination.' ) );
	$page_per_page_arg = array_merge( $per_page_arg, array( 'description' => 'Int representing the number of pages to get per page for pagination.' ) );

	// Register routes.
	register_rest_route( 'elm-press/v1', '/post', array(
		'methods'  => 'GET',
		'callback' => 'rest_get_post',
		'args'     => array(
			'slug' => array_merge( $post_slug_arg, array( 'required' => true ) ),
		),
	) );

	register_rest_route( 'elm-press/v1', '/posts', array(
		'methods'  => 'GET',
		'callback' => 'rest_get_all_posts',
		'args'     => array(
			'per_page' => array_merge( $page_per_page_arg, array( 'required' => false ) ),
		),
	) );

	register_rest_route( 'elm-press/v1', '/page', array(
		'methods'  => 'GET',
		'callback' => 'rest_get_page',
		'args'     => array(
			'slug' => array_merge( $page_slug_arg, array( 'required' => true ) ),
		),
	) );

	register_rest_route( 'elm-press/v1', '/pages', array(
		'methods'  => 'GET',
		'callback' => 'rest_get_all_pages',
		'args'     => array(
			'per_page' => array_merge( $page_per_page_arg, array( 'required' => false ) ),
		),
	) );

	register_rest_route('elm-press/v1', '/post/preview', array(
		'methods'             => 'GET',
		'callback'            => 'rest_get_post_preview',
		'args'                => array(
			'id' => array(
				'validate_callback' => function( $param, $request, $key ) {
					return ( is_numeric( $param ) );
				},
				'required'          => true,
				'description'       => 'Valid WordPress post ID',
			),
		),
		'permission_callback' => function() {
			return current_user_can( 'edit_posts' );
		},
	) );
});

/**
 * Respond to a REST API request to get post data.
 *
 * @param WP_REST_Request $request Request Class holding request data.
 * @return WP_REST_Response
 */
function rest_get_post( WP_REST_Request $request ) {
	return rest_get_content( $request, 'post', __FUNCTION__ );
}

/**
 * Respond to a REST API request to get post data for all posts.
 *
 * @param WP_REST_Request $request Request Class holding request data.
 * @return WP_REST_Response
 */
function rest_get_all_posts( WP_REST_Request $request ) {
	return rest_get_all( $request, 'post', __FUNCTION__ );
}

/**
 * Respond to a REST API request to get page data.
 *
 * @param WP_REST_Request $request Request Class holding request data.
 * @return WP_REST_Response
 */
function rest_get_page( WP_REST_Request $request ) {
	return rest_get_content( $request, 'page', __FUNCTION__ );
}

/**
 * Respond to a REST API request to get page data for all pages.
 *
 * @param WP_REST_Request $request Request Class holding request data.
 * @return WP_REST_Response
 */
function rest_get_all_pages( WP_REST_Request $request ) {
	return rest_get_all( $request, 'page', __FUNCTION__ );
}

/**
 * Respond to a REST API request to get post or page data for all posts or pages.
 * * Returns number of posts based on per_page param
 * * Doesn't return posts whose status isn't published
 *
 * @param WP_REST_Request $request        Request Class holding request data.
 * @param str             $type           Type argument for expected data.
 * @param str             $function_name  Function name to show in case of error.
 * @return WP_REST_Response
 */
function rest_get_all( WP_REST_Request $request, $type, $function_name ) {
	if ( ! in_array( $type, array( 'post', 'page' ), true ) ) {
		$type = 'post';
	}
	$per_page = $request->get_param( 'per_page' );
	$posts = get_posts_with_count( $type, $per_page );
	if ( ! $posts ) {
		return new WP_Error(
			$function_name,
			'There were no ' . $type . 's found.',
			array( 'status' => 404 )
		);
	};

	$controller = new WP_REST_Posts_Controller( 'post' );
	$data       = $controller->prepare_item_for_response( $post, $request );
	$response   = $controller->prepare_response_for_collection( $data );

	return new WP_REST_Response( $response );
}

/**
 * Respond to a REST API request to get post or page data.
 * * Handles changed slugs
 * * Doesn't return posts whose status isn't published
 * * Redirects to the admin when an edit parameter is present
 *
 * @param WP_REST_Request $request        Request Class holding request data.
 * @param str             $type           Type argument for expected data.
 * @param str             $function_name  Function name to show in case of error.
 * @return WP_REST_Response
 */
function rest_get_content( WP_REST_Request $request, $type, $function_name ) {
	if ( ! in_array( $type, array( 'post', 'page' ), true ) ) {
		$type = 'post';
	}
	$slug = $request->get_param( 'slug' );
	$post = get_content_by_slug( $slug, $type );
	if ( ! $post ) {
		return new WP_Error(
			$function_name,
			$slug . ' ' . $type . ' does not exist',
			array( 'status' => 404 )
		);
	};

	// Shortcut to WP admin page editor.
	$edit = $request->get_param( 'edit' );
	if ( 'true' === $edit ) {
		header( 'Location: /wp-admin/post.php?post=' . $post->ID . '&action=edit' );
		exit;
	}
	$controller = new WP_REST_Posts_Controller( 'post' );
	$data       = $controller->prepare_item_for_response( $post, $request );
	$response   = $controller->prepare_response_for_collection( $data );

	return new WP_REST_Response( $response );
}

/**
 * Returns a post or page given a slug. Returns false if no post matches.
 *
 * @param str $slug Slug of current API call.
 * @param str $type Valid values are 'post' or 'page'.
 * @return Post
 */
function get_content_by_slug( $slug, $type = 'post' ) {
	if ( ! in_array( $type, array( 'post', 'page' ), true ) ) {
		$type = 'post';
	}
	$args = array(
		'name'        => $slug,
		'post_type'   => $type,
		'post_status' => 'publish',
		'numberposts' => 1,
	);

	$query               = new WP_Query( $args );
	$post_search_results = $query->posts;

	if ( ! $post_search_results ) { // maybe the slug changed?
		// check wp_postmeta table for old slug.
		$args                = array(
			'meta_query' => array(
				array(
					'key'     => '_wp_old_slug',
					'value'   => $post_slug,
					'compare' => '=',
				),
			),
		);
		$query               = new WP_Query( $args );
		$post_search_results = $query->posts;
	}
	if ( isset( $post_search_results[0] ) ) {
		return $post_search_results[0];
	}
	return false;
}

/**
 * Respond to a REST API request to get a post's latest revision.
 * * Requires a valid _wpnonce on the query string
 * * User must have 'edit_posts' rights
 * * Will return draft revisions of even published posts
 *
 * @param  WP_REST_Request $request Request Class holding request data.
 * @return WP_REST_Response
 */
function rest_get_post_preview( WP_REST_Request $request ) {
	$post_id   = $request->get_param( 'id' );
	$revisions = wp_get_post_revisions( $post_id, array( 'check_enabled' => false ) );
	$post      = get_post( $post_id );
	// Revisions are drafts so here we remove the default 'publish' status.
	remove_action( 'pre_get_posts', 'set_default_status_to_publish' );
	if ( $revisions ) {
		$last_revision = reset( $revisions );
		$rev_post      = wp_get_post_revision( $last_revision->ID );
		$controller    = new WP_REST_Posts_Controller( 'post' );
		$data          = $controller->prepare_item_for_response( $rev_post, $request );
	} elseif ( $post ) { // There are no revisions, just return the saved parent post.
		$controller = new WP_REST_Posts_Controller( 'post' );
		$data       = $controller->prepare_item_for_response( $post, $request );
	} else {
		return new WP_Error(
			'rest_get_post_preview', 'Post ' . $post_id . ' does not exist',
			array( 'status' => 404 )
		);
	}
	$response = $controller->prepare_response_for_collection( $data );
	return new WP_REST_Response( $response );
}

