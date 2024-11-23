//Создаём сервисный аккаунт avminkov 
resource "yandex_iam_service_account" "sa" {
	name        = "avminkov-sa"   
	description = "service account to manage k8s"
}


data "yandex_resourcemanager_folder" "otus" {
  name = "otus"
}


resource "yandex_resourcemanager_folder_iam_binding" "admin" {
  folder_id = "${data.yandex_resourcemanager_folder.otus.id}"

  role = "admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}


resource "yandex_resourcemanager_folder_iam_binding" "admin-s3" {
  folder_id = "${data.yandex_resourcemanager_folder.otus.id}"

  role = "storage.admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}


// Creating a static access key
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}


//Создаём ключи для k8s
resource "yandex_kms_symmetric_key" "key-a" {
  name              = "key"
  description       = "key for k8s"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}


resource "yandex_vpc_network" "k8s-net" {
  name = "k8s-network"
  description = "Сеть для k8s"
}


resource "yandex_vpc_subnet" "subnet-a-k8s-cluster1" {
  name = "subnet-a-k8s-cluster1"
  description = "Subnet that reserves CIDR block for Kubernetes Cluster"
  v4_cidr_blocks = ["172.16.0.0/20"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.k8s-net.id}"
}


resource "yandex_vpc_subnet" "subnet-a-k8s-cluster2" {
  name = "subnet-a-k8s-cluster2"
  description = "Subnet that reserves CIDR block for Kubernetes Cluster"
  v4_cidr_blocks = ["172.16.16.0/20"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.k8s-net.id}"
}


resource "yandex_vpc_security_group" "vpc_security_group" {
  name        = "vpc_security_group"
  description = "description for my security group"
  network_id  = "${yandex_vpc_network.k8s-net.id}"

  labels = {
    my-label = "my-label-value"
  }

  ingress {
    protocol       = "TCP"
    description    = "rule1 description"
    v4_cidr_blocks = ["10.0.1.0/24"]
    port           = 8080
  }

  egress {
    protocol       = "ANY"
    description    = "rule2 description"
    v4_cidr_blocks = ["10.0.1.0/24"]
    from_port      = 8090
    to_port        = 8099
  }

  egress {
    protocol       = "UDP"
    description    = "rule3 description"
    v4_cidr_blocks = ["10.0.1.0/24"]
    from_port      = 8090
    to_port        = 8099
  }
}

resource "yandex_kubernetes_cluster" "k8s-cluster" {
  name        = "k8scluster"
  description = "Сделал в рамках учебного задания..."

  master {
    version = "1.28"
    zonal {
      zone      = "${yandex_vpc_subnet.subnet-a-k8s-cluster1.zone}"
      subnet_id = "${yandex_vpc_subnet.subnet-a-k8s-cluster1.id}"
    }

    public_ip = true

//    security_group_ids = ["${yandex_vpc_security_group.vpc_security_group.id}"]

    maintenance_policy {
      auto_upgrade = false
    }
  }

  service_account_id      = "${yandex_iam_service_account.sa.id}"
  node_service_account_id = "${yandex_iam_service_account.sa.id}"

  release_channel = "STABLE"
  network_policy_provider = "CALICO"

  kms_provider {
    key_id = "${yandex_kms_symmetric_key.key-a.id}"
  }

  network_id = "${yandex_vpc_network.k8s-net.id}"
  cluster_ipv4_range = "172.17.0.0/20"
  service_ipv4_range = "172.17.16.0/20"

}

//------------------------------------------------------------------------------------------------------------------

resource "yandex_kubernetes_node_group" "k8s-workers" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s-cluster.id}"
  name        = "k8s-cluster-workers"
  description = "workers для k8s-cluster"
  version     = "1.28"


  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.subnet-a-k8s-cluster1.id}"]
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 60
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = "${yandex_vpc_subnet.subnet-a-k8s-cluster1.zone}"
    }
  }
}

//------------------------------------------------------------------------------------------------------------------

resource "yandex_kubernetes_node_group" "k8s-infara" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s-cluster.id}"
  name        = "k8s-cluster-infara"
  description = "infra для k8s-cluster"
  version     = "1.28"


  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.subnet-a-k8s-cluster1.id}"]
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 60
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = "${yandex_vpc_subnet.subnet-a-k8s-cluster1.zone}"
    }
  }
}

// Creating a bucket using a key
resource "yandex_storage_bucket" "otus" {
  access_key            = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key            = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket                = "otus3"
  max_size              = 10073741824
  default_storage_class = "standard"
  anonymous_access_flags {
    read        = true
    list        = true
    config_read = true
  }
}

// Creating a bucket using a key
//resource "yandex_storage_bucket" "test" {
//  access_key            = yandex_iam_service_account_static_access_key.sa-static-key.access_key
//  secret_key            = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
//  bucket                = "loki"
//  max_size              = 2147483648
//  default_storage_class = "standard"
//  anonymous_access_flags {
//    read        = true
//    list        = true
//    config_read = true
//  }
//  tags = {
//    "otus_test" = "test"
//  }
//}
