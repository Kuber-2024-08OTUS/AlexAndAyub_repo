SECRET_NAME=$(kubectl get sa $1 -n homework -o jsonpath="{.secrets[0].name}")
TOKEN=$(kubectl get secret $SECRET_NAME -n homework -o jsonpath="{.data.token}" | base64 --decode)
CA_CRT=$(kubectl get secret $SECRET_NAME -n homework -o jsonpath="{.data['ca\.crt']}" | base64 --decode | base64 -w 0)
APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

envsubst < kubeconfig.tmp > kubeconfig-$1-final
