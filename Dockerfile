FROM node:12.18.4 as build

WORKDIR /tmp

COPY . .
RUN npm cache verify
RUN npm cache clean -f
RUN yarn --ignore-optional --network-timeout 600000

ARG NODE_ENV=production

COPY . .
RUN yarn build:app:docker

# 安装依赖并构建
RUN npm install --registry https://registry.npm.taobao.org && npm run build

# 以nginx:1.12.2为基础镜像
# nginx后面跟的tag，可以在docker hub中（上方网址）查找项目所需的tag
FROM nginx:1.12.2

# 修改/usr/share/nginx/html里面的内容为前端需要部署的静态文件，这样前端就跑在nginx上了
WORKDIR /usr/share/nginx/html
RUN rm -f *
COPY --from=build /tmp/dist .

# 替换default.conf文件，解决单页面部署后刷新404问题
COPY --from=build /tmp/configs/nginx.conf /etc/nginx/conf.d/default.conf
