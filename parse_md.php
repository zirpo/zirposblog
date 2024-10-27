<?php
function parseMarkdown($text) {
    // Headers
    $text = preg_replace('/^#\s(.*)$/m', '<h1>$1</h1>', $text);
    $text = preg_replace('/^##\s(.*)$/m', '<h2>$1</h2>', $text);
    $text = preg_replace('/^###\s(.*)$/m', '<h3>$1</h3>', $text);

    // Bold
    $text = preg_replace('/\*\*(.*?)\*\*/', '<strong>$1</strong>', $text);

    // Italic
    $text = preg_replace('/\*(.*?)\*/', '<em>$1</em>', $text);

    // Images (add this before Links)
    $text = preg_replace('/!\[(.*?)\]\((.*?)\)/', '<img src="$2" alt="$1">', $text);

    // Links
    $text = preg_replace('/\[(.*?)\]\((.*?)\)/', '<a href="$2">$1</a>', $text);

    // Lists
    $text = preg_replace('/^\s*\*\s(.*)$/m', '<li>$1</li>', $text);
    $text = preg_replace('/(<li>.*<\/li>)/', '<ul>$1</ul>', $text);

    // Paragraphs
    $text = '<p>' . preg_replace('/\n\n/', '</p><p>', $text) . '</p>';

    return $text;
}

function getPostTitle($filename) {
    $content = file_get_contents($filename);
    $lines = explode("\n", $content);
    foreach ($lines as $line) {
        if (strpos($line, '#') === 0) {
            return trim(str_replace('#', '', $line));
        }
    }
    return basename($filename, '.md');
}
?>
