<?php
require_once 'parse_md.php';

function getPostExcerpt($filename, $length = 150) {
    $content = file_get_contents($filename);
    $content = preg_replace('/!\[.*?\]\(.*?\)/', '', $content); // Remove image markdown
    $content = strip_tags($content);
    return substr($content, 0, $length) . '...';
}

$posts = glob('markdown/*.md');
usort($posts, function($a, $b) {
    return filemtime($b) - filemtime($a);
});

$latest_post = $posts[0];
$latest_post_title = getPostTitle($latest_post);
$latest_post_excerpt = getPostExcerpt($latest_post);
$latest_post_filename = basename($latest_post, '.md');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>zirpo's blog</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>zirpo's blog</h1>
        </header>
        <main>
            <section class="latest-post">
                <h2><?php echo $latest_post_title; ?></h2>
                <p><?php echo $latest_post_excerpt; ?></p>
                <a href="view_post.php?post=<?php echo $latest_post_filename; ?>" class="read-more">Read More</a>
            </section>

            <h2>Posts</h2>
            <ul>
                <?php
                foreach ($posts as $post) {
                    $title = getPostTitle($post);
                    $filename = basename($post, '.md');
                    echo "<li><a href='view_post.php?post=$filename'>$title</a></li>";
                }
                ?>
            </ul>
        </main>
    </div>
</body>
</html>
