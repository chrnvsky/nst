# Установка gitlab-runner в k8s

Регистрация раннера и получения токена

Settings > CI/CD > Runners > Register a new runner

Скопируем registration token

Добавляем репозиторий Helm для Gitlab

```
helm repo add gitlab https://charts.gitlab.io
helm repo update
```
Выбираем версию и пулим chart для редактирования values.yml

```
helm search repo -l gitlab/gitlab-runner

helm pull gitlab/gitlab-runner --untar
```

Создаем override-values.yaml

```
nano override-values.yaml
```

Меняем переменные (пример)

```
gitlabUrl: https://gitlab.com
runnerToken: "" # лучше указать в gitlab переменных или секретах k8s
runners:
  tags: k8s-runner
  executor: kubernetes
  kubernetes:
    namespace: gitlab-runner
    image: alpine
    cpu_limit: "1"
    memory_limit: "1Gi"	

rbac:
  create: true

serviceAccount:
  create: true
  name: gitlab-runner
```

Запускаем чарт

```
helm install gitlab-runner -n gitlab-runner --create-namespace -f override-values.yaml gitlab/gitlab-runner
```