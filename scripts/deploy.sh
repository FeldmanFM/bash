n=1; for i in `ls ../output/`; do ../output/$i/deploy.sh node$n; n=$(( $n+1 )); done
