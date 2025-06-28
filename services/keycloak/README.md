# 🛡️ Keycloak Local Development Realm

This setup provides a fully functional **Keycloak development realm** with preconfigured users and roles for local testing. It is meant to support full-stack development and authentication workflows using [OpenID Connect (OIDC)].

---

## 🔑 Access Keycloak

Once the Keycloak container is running:

🌐 Go to: [https://localhost:8005/auth](https://localhost:8005/auth)

🧑‍💼 **Admin Console Login**

| Username | Password                           |
| -------- | ---------------------------------- |
| `admin`  | `6UE7nLjzv3F86qkChHwXaZoftMgYlazl` |

---

## 🧪 Preconfigured Test Users

| Username      | Email                         | Password    | First Name | Last Name   | Role          |
| ------------- | ----------------------------- | ----------- | ---------- | ----------- | ------------- |
| `root.smith`  | `root@universal.dev`          | `Root123!`  | Root       | Smith       | `superuser`   |
| `admin.jane`  | `jane.admin@universal.dev`    | `Admin123!` | Jane       | Admin       | `admin`       |
| `edit.alex`   | `alex.editor@universal.dev`   | `Edit123!`  | Alex       | Editor      | `editor`      |
| `view.emma`   | `emma.viewer@universal.dev`   | `View123!`  | Emma       | Viewer      | `viewer`      |
| `contrib.lee` | `lee.contrib@universal.dev`   | `Cont123!`  | Lee        | Contributor | `contributor` |
| `mgr.davis`   | `davis.manager@universal.dev` | `Mgr123!`   | Davis      | Manager     | `manager`     |
| `ana.kim`     | `kim.analyst@universal.dev`   | `Data123!`  | Kim        | Analyst     | `analyst`     |
| `dev.sam`     | `sam.dev@universal.dev`       | `Dev123!`   | Sam        | Eloper      | `developer`   |

---

## 🌱 Realm Info

- 🧩 **Realm Name**: `development`
- 🏷️ **Display Name**: `Universal Development Realm`
- 🌍 **Issuer URL**: `https://localhost:8005/auth/realms/development`
- 💡 OIDC Discovery URL:
  `https://localhost:8005/auth/realms/development/.well-known/openid-configuration`

---

## 📦 Realm Export

If you ever want to re-export the realm (after editing):

```bash
docker exec -it keycloak \
  /opt/keycloak/bin/kc.sh export \
  --file=/opt/keycloak/data/import/development-realm.json \
  --realm=development \
  --users=same_file
```
