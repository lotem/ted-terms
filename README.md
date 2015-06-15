#ted-terms

从 XML 提取术语定义。

## 用法

输出到文件：

``` batch
run.bat < sample.xml > output.yaml
```

假定输入文件编码为 GBK，输出文件编码为 UTF-16LE。
可在 `config.js` 里面设定。

指定输出格式：

``` batch
run.bat --format=csv < sample.xml > output.csv

run.bat -f json < sample.xml > output.json
```

可选 `csv, json, yaml` 等格式。

调试模式，在控制台查看结果：

``` batch
run.bat --debug < sample.xml

run.bat -d -f json < sample.xml
```
