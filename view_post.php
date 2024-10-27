<?php
require_once 'parse_md.php';

$post = isset($_GET['post']) ? $_GET['post'] : '';
$file = "markdown/$post.md";

if (!file_exists($file)) {
    die("Post not found");
}

$title = getPostTitle($file);
$content = file_get_contents($file);
$html_content = parseMarkdown($content);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($title); ?> - zirpo's blog</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <p><a href="index.php">← Back to Home</a></p>
        <main>
            <article>
                <?php echo $html_content; ?>
            </article>
        </main>
    </div>
</body>
</html>
