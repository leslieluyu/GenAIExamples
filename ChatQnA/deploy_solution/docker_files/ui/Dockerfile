# 使用官方Node.js镜像作为基础镜像
FROM node:latest

ENV LANG C.UTF-8
ENV http_proxy http://proxy-prc.intel.com:911
ENV https_proxy http://proxy-prc.intel.com:912

# 设置工作目录
WORKDIR /app

# 将package.json和package-lock.json复制到工作目录
COPY . .

# 安装项目依赖
RUN npm install

# 将项目源代码复制到工作目录

# 构建项目
CMD ["npm", "run", "dev"]
