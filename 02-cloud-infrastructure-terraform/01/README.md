# Задане 1. Terraform.

1. Установлен Terraform:
![img.png](img.png)

2. Установлен Docker:
![img_1.png](img_1.png)

3. .gitignore - *personal.auto.tfvars*, а вообще желательно все хранить в внешних хранилищах: Hashicorp Vault, Jenkins Credentials, GitHub Secrets и т.д.

4. Вывод пароля:
![img_2.png](img_2.png)
я сделал через json, но можно было поставить `sensitive = false` в `main.tf` у блока с паролем

5. Поправили и расскоментировали блок с докером:
![img_3.png](img_3.png)

6. Подняли nginx с помощью `terraform apply`:
![img_4.png](img_4.png)

7. Сделали `terraform destroy`:
![img_5.png](img_5.png)

8. Из-за `keep_locally = true` образ не удаляется при `destroy`.