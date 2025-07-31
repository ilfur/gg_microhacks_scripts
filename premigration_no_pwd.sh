./premigration.sh --connectstring "jdbc:oracle:thin:@$SRC_URL" --targetcloud ATPS --schemas $SRC_SCHEMA --outdir migration --username system <<EOF
$ADMIN_PWD
EOF

