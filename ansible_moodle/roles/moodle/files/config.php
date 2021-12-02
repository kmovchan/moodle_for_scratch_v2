<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'dev-rds.c511fhlo2fcr.eu-west-3.rds.amazonaws.com';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'root';
$CFG->dbpass    = 'JcUqfl0fhIlvtdDy';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => 3306,
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_general_ci',
);

$CFG->wwwroot   = 'http://alb-dev-353718871.eu-west-3.elb.amazonaws.com';
$CFG->dataroot  = '/mnt/efs/moodledata';
$CFG->cachedir = '/mnt/efs/moodle/cache';    // requried lock, that's why on shared location
$CFG->tempdir = '/mnt/efs/moodle/temp';
$CFG->admin     = 'admin';
$CFG->dirroot = '/var/www/html/moodle';
$CFG->localcachedir = '/var/www/moodle/localcache';

// $CFG->tempdir            = ‘/var/www/html/moodledata/temp’;
// $CFG->cachedir           = ‘/var/www/html/moodledata/cache’;

$CFG->directorypermissions = 0777;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
