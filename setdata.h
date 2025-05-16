void setdata(char* data, int ctr) {
    data[0] = ((ctr % 2) * (ctr % 3) * (ctr % 7)) ? 'a' : 0;
}

void setdata_valid(char* data) {
    data[0] = 'a';
}

void setdata_invalid(char* data) {
    data[0] = 'a';
}
