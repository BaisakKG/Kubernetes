# K8S теория
## Master кластера
* Apiserver (kubectl) - это мозг мастера который принимает файл манифест в Json фомате описывающий состояние приложения
* Cluster store - это постоянное хранилище, хранит состояние кластера и конфиги, использует etcd(хранилище значений распределенных ключей)(NoSQL CoreOS) как источник истины для кластера. Нет Cluster store нет кластера! Поэтому надо делать бекап.
* Controller(kube-controller-manager) - это контроллер контроллеров:
	* Node контроллер
	* Endpoints контроллер
	* Namespace контроллер
	* и тд
	Их задача смотреть за изменениями и helps maintain **desired state**
* Scheduler (kube-scheduler) - watches apiserver for new pods
	Assigns work to node
	* affinity/anti-affinity
	* constraints
	* resources
	* ...
	
## Nodes
* Kubelet - агент на хосте который отвечает за выполнение приказов от мастера и после отчитывается перед мастером, слушает порт 10255
  * /spec - информация об узле
  * /healthz - проверка работоспособности
  * /pods - показывает запуск pods
* Container Engine - управления контейнерами(pods) Dockers or CoreOS
* Kube-proxy - сетевой мозг узла, балансировка

## Pod
Kubernetes запускает контейнеры внутри стручков(Pod), внутри одного пода можно запускать несколько контейнров но лучше каждый контейнер запускать в своем поде для масштабирования и безопасности, можно запускать несколько контейнеров в одном поде если у них общие ресурсы.
Поды атомарные и умирающие, пэтому приложения надо создавать с этим учетом.

## Services
Никогда нельзя пологатся на айпиадреса подов, потому что они всегда меняются при смерти или скейлинге и здесь нам поможет сервис, описываем его в манифест файле ямл чтобы он мог обслуживать(IP&DNS) фронт при связке с бекендом БД.
Отправляет трафик только к здоровым подам, можно настроить сессию, отправлять трафик вне кластера, работает по TCP по умолчанию
* Lables - через ярлыки можно привязать поды к сервису чтобы он их балансировал, также используется при обновлении подов

## Deployments
* Replication Controller
  * Scale pods, desired state ..
Yaml > Apiserver > Replication Controller(Replica Sets)> Blue-Green Deployments OR Canary releases OR Rollback(если что-то пошло не так)

# K8S практика

## Install k8s
** Minikube > Google Container Engine (GKE) > AWS > Manuall install **

### Minikube
* Установка в Mac
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.1/bin/linux/amd64/kubectl
chmod u+x kubectl && mv kubectl /bin/kubectl
kubectl version --client
homebrew install minikube
homebrew install docker-machine-driver-xhyve
	надо включить в группу рут и запустить его как рут
minikube start --vm-driver=xhyve

kubectl config current-context
	kubectl может общатся с любым кластером надо тока сделать свич контекст
kubectl get nodes
minikube stop
minikube delete
minikube start --vm-driver=xhyve --kubernetes-version="v1.6.0"
kubectl get nodes
```
* Установка в Windows
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/windows/amd64/kubectl.exe
https://github.com/kubernetes/minikube/releases/tag/v1.9.2

PowerShell:
minikube version
minikube start --vm-driver=hyperv --kubernetes-version="v1.6.0"
kubectl get pods
minikube
minikube dashboard
	Namespace>kube-system>pods
```
### Google Container Engine (GKE)
* Создаем аккаунт
* Создаем проект
* Настроиваем биллинг
* Container Engine
	* Create container cluster
		Node image: cos (Chromium OS)
		Size: 3 (миньона или node)
		Create
		Copy: Connect to the cluster
	* Shell
		```
		gcloud container cluster list
		Copy: Connect to the cluster
			kubectl get nodes
		```
	* Web 
		Show credintials
		https://IP-ADDRESS/ui

### AWS
* Pre-req: ** kubectl, kops, AWS CLI ** 	
* IAM account in AWS with:
	AmazonEC2FullAccess
	AmazonRoute53FullAccess
	AmazonS3FullAccess
	IAMFullAccess
	AmazonVPCFullAccess

### Manual install
* Every node (master and minions) needs:
	* Docker (or rkt)
	* Kubelet
	* Kubeadm
	* Kubectl
	* CNI
```
kubeadm init
kubeadm join --token <token>
```