<?php
// Configuración para evitar errores de visualización
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Función para verificar extensiones
function check_extension($ext) {
    return extension_loaded($ext) ?
        '<span class="text-success">✓ Activada</span>' :
        '<span class="text-danger">✗ No activada</span>';
}

// Función para formatear bytes a un formato legible
function format_size($bytes) {
    if ($bytes >= 1073741824) {
        return round($bytes / 1073741824, 2) . ' GB';
    } elseif ($bytes >= 1048576) {
        return round($bytes / 1048576, 2) . ' MB';
    } elseif ($bytes >= 1024) {
        return round($bytes / 1024, 2) . ' KB';
    } else {
        return $bytes . ' bytes';
    }
}

$docRoot = $_SERVER['DOCUMENT_ROOT'] ?? '/';
$totalSpace = @disk_total_space($docRoot);
$freeSpace = @disk_free_space($docRoot);
$usedSpace = $totalSpace - $freeSpace;
$diskUsagePercentage = $totalSpace ? round(($usedSpace / $totalSpace) * 100, 2) : 'N/A';

?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebServer | Shoropio</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-SgOJa3DmI69IUzQ2PVdRZhwQ+dy64/BUtbMJw1MZ8t5HZApcHrRKUc4W0kG879m7" crossorigin="anonymous" />
    <!-- <link rel="apple-touch-icon" href="/docs/5.3/assets/img/favicons/apple-touch-icon.png" sizes="180x180" />
    <link rel="icon" href="/docs/5.3/assets/img/favicons/favicon-32x32.png" sizes="32x32" type="image/png"/>
    <link rel="icon" href="/docs/5.3/assets/img/favicons/favicon-16x16.png" sizes="16x16" type="image/png" />
    <link rel="manifest" href="/docs/5.3/assets/img/favicons/manifest.json" />
    <link rel="mask-icon" href="/docs/5.3/assets/img/favicons/safari-pinned-tab.svg" color="#712cf9">
    <link rel="icon" href="/docs/5.3/assets/img/favicons/favicon.ico" /> -->
    <meta name="theme-color" content="#712cf9" />
    <!-- Styles -->
    <style>.card{border-radius:0!important}.navbar-toggler{border-radius:0!important}.btn{border-radius:0!important}.card-header:first-child{border-radius:0!important}</style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="#">WebServer</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link active" aria-current="page" href="#server-info">Información del servidor</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#database-info">Base de datos</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#php-extensions">Extensiones PHP</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#other-tools">Otras Herramientas</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container py-4 text-center">
        <div class="row row-cols-1 row-cols-md-2 g-4">
            <div class="col" id="server-info">
                <div class="card shadow-sm">
                <div class="card-header bg-dark">
                    <h5 class="card-title text-light" style="margin-bottom:0px;">Información del servidor</h5>
                </div>
                    <div class="card-body" style="padding-bottom: 0px;">
                        <table class="table table-sm table-hover table-bordered">
                            <thead class="table-dark">
                                <tr>
                                    <th>Variable</th>
                                    <th>Valor</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Servidor</td>
                                    <td><?= $_SERVER['SERVER_SOFTWARE'] ?? 'N/A' ?></td>
                                </tr>
                                <tr>
                                    <td>PHP</td>
                                    <td><?= phpversion() ?></td>
                                </tr>
                                <tr>
                                    <td>SAPI</td>
                                    <td><?= php_sapi_name() ?></td>
                                </tr>
                                <tr>
                                    <td>OS</td>
                                    <td><?= php_uname() ?></td>
                                </tr>
                                <tr>
                                    <td>Root</td>
                                    <td><?= $_SERVER['DOCUMENT_ROOT'] ?? 'N/A' ?></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col" id="database-info">
                <div class="card shadow-sm">
                    <div class="card-header bg-dark">
                        <h5 class="card-title text-light" style="margin-bottom:0px;">Base de datos</h5>
                    </div>
                    <div class="card-body" style="padding-bottom: 0px;">
                    <?php
                    mysqli_report(MYSQLI_REPORT_OFF); // Desactivar excepciones automáticas temporalmente
                    $db_connection = @mysqli_connect('localhost', 'root', '');

                    // Primero, verificamos si la conexión fue exitosa
                    if ($db_connection) {
                        $mysql_version = mysqli_get_server_info($db_connection);

                        if (stripos($mysql_version, 'MariaDB') !== false) {
                            $motor = 'MariaDB';
                        } else {
                            $motor = 'MySQL';
                        }

                        echo '<table class="table table-sm table-hover table-bordered">';
                        echo '<thead class="table-dark"><tr><th>Variable</th><th>Valor</th></tr></thead>';
                        echo '<tbody>';
                        echo '<tr><td>Versión de ' . $motor . '</td><td>' . htmlspecialchars($mysql_version) . '</td></tr>';
                        echo '<tr><td>Host info</td><td>' . htmlspecialchars(mysqli_get_host_info($db_connection)) . '</td></tr>';
                        echo '<tr><td>Protocolo</td><td>' . htmlspecialchars(mysqli_get_proto_info($db_connection)) . '</td></tr>';
                        echo '</tbody>';
                        echo '</table>';

                        mysqli_close($db_connection);
                    } else {
                        echo '<p class="text-danger">Ha ocurrido un error: ' . (mysqli_connect_error() ?? 'Error desconocido') . '</p>';
                    }
                    ?>
                    </div>
                </div>
            </div>

            <div class="col" id="php-info">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title">Configuración de PHP</h5>
                        <table class="table table-sm table-hover">
                            <tbody>
                                <tr>
                                    <th>`php.ini` Path</th>
                                    <td><?= php_ini_loaded_file() ?></td>
                                </tr>
                                <tr>
                                    <th>`memory_limit`</th>
                                    <td><?= ini_get('memory_limit') ?></td>
                                </tr>
                                <tr>
                                    <th>`upload_max_filesize`</th>
                                    <td><?= ini_get('upload_max_filesize') ?></td>
                                </tr>
                                <tr>
                                    <th>`post_max_size`</th>
                                    <td><?= ini_get('post_max_size') ?></td>
                                </tr>
                                <tr>
                                    <th>`max_execution_time`</th>
                                    <td><?= ini_get('max_execution_time') ?> segundos</td>
                                </tr>
                                <tr>
                                    <th>`display_errors`</th>
                                    <td><?= ini_get('display_errors') ? '<span class="text-success">Activado</span>' : '<span class="text-danger">Desactivado</span>' ?></td>
                                </tr>
                                <tr>
                                    <th>`error_reporting`</th>
                                    <td><?= ini_get('error_reporting') ?></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col" id="disk-space">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title">Espacio en disco (<?= $docRoot ?>)</h5>
                        <table class="table table-sm table-hover">
                            <tbody>
                                <tr>
                                    <th>Espacio Total</th>
                                    <td><?= $totalSpace ? format_size($totalSpace) : 'N/A' ?></td>
                                </tr>
                                <tr>
                                    <th>Espacio Usado</th>
                                    <td><?= $totalSpace ? format_size($usedSpace) . ' (' . $diskUsagePercentage . '%)' : 'N/A' ?></td>
                                </tr>
                                <tr>
                                    <th>Espacio Libre</th>
                                    <td><?= $freeSpace ? format_size($freeSpace) : 'N/A' ?></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col" id="php-extensions">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title">Extensiones PHP</h5>
                        <table class="table table-sm table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>Extensión</th>
                                    <th>Estado</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr><td>MySQLi</td><td><?= check_extension('mysqli') ?></td></tr>
                                <tr><td>PDO MySQL</td><td><?= check_extension('pdo_mysql') ?></td></tr>
                                <tr><td>cURL</td><td><?= check_extension('curl') ?></td></tr>
                                <tr><td>GD</td><td><?= check_extension('gd') ?></td></tr>
                                <tr><td>OpenSSL</td><td><?= check_extension('openssl') ?></td></tr>
                                <tr><td>MBString</td><td><?= check_extension('mbstring') ?></td></tr>
                                <tr><td>XML</td><td><?= check_extension('xml') ?></td></tr>
                                <tr><td>JSON</td><td><?= check_extension('json') ?></td></tr>
                                <tr><td>ZIP</td><td><?= check_extension('zip') ?></td></tr>

                                <tr><td>Intl</td><td><?= check_extension('intl') ?></td></tr>
                                <tr><td>BCMath</td><td><?= check_extension('bcmath') ?></td></tr>
                                <tr><td>SOAP</td><td><?= check_extension('soap') ?></td></tr>
                                <tr><td>Iconv</td><td><?= check_extension('iconv') ?></td></tr>
                                <tr><td>Fileinfo</td><td><?= check_extension('fileinfo') ?></td></tr>
                                <tr><td>Tokenizer</td><td><?= check_extension('tokenizer') ?></td></tr>

                                <tr><td>EXIF</td><td><?= check_extension('exif') ?></td></tr>
                                <tr><td>Imagick</td><td><?= check_extension('imagick') ?></td></tr>

                                <tr><td>Redis</td><td><?= check_extension('redis') ?></td></tr>
                                <tr><td>Memcached</td><td><?= check_extension('memcached') ?></td></tr>

                                <tr><td>SimpleXML</td><td><?= check_extension('simplexml') ?></td></tr>
                                <tr><td>DOM</td><td><?= check_extension('dom') ?></td></tr>
                                <tr><td>Readline</td><td><?= check_extension('readline') ?></td></tr>
                                <tr><td>FTP</td><td><?= check_extension('ftp') ?></td></tr>
                                <tr><td>LDAP</td><td><?= check_extension('ldap') ?></td></tr>
                                <tr><td>Xdebug</td><td><?= check_extension('xdebug') ?></td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col" id="other-tools">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title">Otras herramientas</h5>
                        <table class="table table-sm table-hover">
                            <tbody>
                                <tr>
                                    <td>phpMyAdmin</td>
                                    <td><a href="https://phpmyadmin.local" class="btn btn-primary btn-sm" target="_blank">Acceder a phpMyAdmin</a></td>
                                </tr>
                                <tr>
                                    <td>PHP Info</td>
                                    <td><a href="/phpinfo.php" class="btn btn-primary btn-sm" target="_blank">Ver phpinfo() completo</a></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="bg-dark py-3 mt-4 border-top">
        <div class="container text-center">
            <p class="text-light small" style="margin-bottom: 0px;">{{SERVER_NAME}} - {{AUTHOR}} {{YEAR}}</p>
        </div>
    </footer>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.bundle.min.js" integrity="sha384-k6d4wzSIapyDyv1kpU366/PK5hCdSbCRGRCMv+eplOQJWyd1fbcAu9OCUj5zNLiq" crossorigin="anonymous"></script>
</body>
</html>