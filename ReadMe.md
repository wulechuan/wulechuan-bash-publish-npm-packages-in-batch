# 批量发布 npm 包至特定注册点的工具

## 简介

我们可以借助 [verdaccio](https://verdaccio.org/) 这样的工具搭建私有 npm 注册点服务器，简称私有 npm 服务器。

但要方便的将大批 npm 包的 `.tgz` 文件导入我们的私有 npm 服务器则没有现成工具。本人遂构建本工具，以较为方便的将已经在本机的某些 node_modules 文件夹内的 npm 包，批量【发布】（`publish`）到我们的私有 npm 服务器上。

本工具是一个 bash 脚本，内部调用 `npm  publish  "文件夹路径"` 命令来发布 npm 包至指定 npm 服务器。默认的 npm 服务器为 verdaccio 搭建的 `http://localhost:4873`。

---

## 用法

本工具分为两个独立的 bash 脚本，如下：

1. `1-search-a-folder-and-download-all-tgz-files.sh`，用于《[深度扫描一个文件夹中的所有已安装包，并自动从淘宝注册点下载其对应的tgz文件](#深度扫描一个文件夹中的所有已安装包，并自动从淘宝注册点下载其对应的tgz文件)》

2. `2-scan-cached-tgz-files-and-publish-them.sh`，用于《[扫描已缓存的所有tgz文件，并将它们发布到私有注册点](#扫描已缓存的所有tgz文件，并将它们发布到私有注册点)》。

### 深度扫描一个文件夹中的所有已安装包，并自动从淘宝注册点下载其对应的tgz文件

#### 语法

```bash
source  "<本工具路径>/1-search-a-folder-and-download-all-tgz-files.sh"  ["<深度搜索所有node_modules文件夹的起始文件夹路径>"]  ["<注册点服务器的URL>"]
```

#### 示例

假定该工具存放在 `/d/tools` 文件夹中。

- 从当前文件夹开始深度搜索：

    ```bash
    source  "/d/tools/1-search-a-folder-and-download-all-tgz-files.sh"
    ```

- 从指定文件夹（`/c/Users/wulechuan/AppData/Roaming/npm/`）开始深度搜索：

    ```bash
    source  "/d/tools/1-search-a-folder-and-download-all-tgz-files.sh"  "/c/Users/wulechuan/AppData/Roaming/npm/"
    ```

- 发布到指定的注册点：

    ```bash
    source  "/d/tools/1-search-a-folder-and-download-all-tgz-files.sh"  "/c/Users/wulechuan/AppData/Roaming/npm/"  "https://registry.npmjs.com"
    ```

### 扫描已缓存的所有tgz文件，并将它们发布到私有注册点

#### 语法

```bash
source  "<本工具路径>/2-scan-cached-tgz-files-and-publish-them.sh"
```

#### 示例

假定该工具存放在 `/d/tools` 文件夹中。

- 示例：

    ```bash
    source  "/d/tools/2-scan-cached-tgz-files-and-publish-them.sh"
    ```

---

## 已知问题

### 问题列表

- 如果一个包的新版本先被发布到注册点服务器，那么稍后再发布较旧版本会被拒绝。而我的 bash 脚本还不能完美的对同一个包的多个版本的 `.tgz` 文件依照版本先后排序，而仅能凭借 bash 的 `find` 命令对这些 `.tgz` 文件依照字母表顺序排序。因此，可能遭遇潜在的发布问题。
