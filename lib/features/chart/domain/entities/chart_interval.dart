enum ChartInterval {
  h1('1h', '1s'),
  h4('4h', '4s'),
  d1('1d', '1g');

  final String apiValue;
  final String label;

  const ChartInterval(this.apiValue, this.label);
}
