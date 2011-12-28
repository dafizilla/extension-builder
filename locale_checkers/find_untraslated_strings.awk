BEGIN {
    len = split(ARGV[1], a, "/")
    fileName = tolower(a[len]);
}
    
fileName ~ /\.dtd$/ && $0 ~ /^<!ENTITY/ {
    // Process DTD files
    printf("%-30s:%s\n", fileName, $0)
}

fileName ~ /\.properties$/ && $0 ~ /^.*=/ {
    printf("%-30s:%s\n", fileName, $0)
}
