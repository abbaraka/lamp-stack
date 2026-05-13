<?php
# Load environment variables from .env file
$env = parse_ini_file('../.env');

# Database connection using environment variables
$conn = new mysqli(
    $env['DB_HOST'],
    $env['DB_USER'],
    $env['DB_PASSWORD'],
    $env['DB_NAME']
);

# Check connection
if ($conn->connect_error) {
    die('Connection failed. Please check your .env configuration.');
}

# Query visitors table
$result = $conn->query('SELECT * FROM visitors');
?>
<!DOCTYPE html>
<html>
<head>
    <title>MILENA HOST WEB SERVER LAMP Stack v1</title>
</head>
<body>
    <h1>LAMP Stack v1</h1>
    <p>A simple LAMP stack deployment.</p>
    <hr>

    <h2>Server Information</h2>
    <p>Date and time: <?php echo date('Y-m-d H:i:s'); ?></p>

    <hr>
    <h2>Visitors</h2>
    <?php if ($result && $result->num_rows > 0): ?>
        <table border="1">
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Visit Time</th>
            </tr>
            <?php while ($row = $result->fetch_assoc()): ?>
            <tr>
                <td><?php echo htmlspecialchars($row['id']); ?></td>
                <td><?php echo htmlspecialchars($row['name']); ?></td>
                <td><?php echo htmlspecialchars($row['visit_time']); ?></td>
            </tr>
            <?php endwhile; ?>
        </table>
    <?php else: ?>
        <p>No visitors found.</p>
    <?php endif; ?>

    <?php $conn->close(); ?>

    <hr>
    <footer>
        <small>
            LAMP Stack v1 |
            HTTP only (HTTPS in v2) |
            Single server (Load balancing in v2)
        </small>
    </footer>
</body>
</html>
