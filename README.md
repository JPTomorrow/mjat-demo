# MJAT Demo

This is a project for an interview to spool up flight simulations in a godot game engine using kubernetes.

- readme in client / server folders will tell you how to build docker containers for each
- look in the k8-deployments folder for kubernetes deployments after you build the docker containers

## deploy with kubernetes
```
kubectl apply -f k8-deployments/
```

## reset kubernetes deployments
```
kubectl rollout restart deployment
```

## kubernetes port forward hack for local testing

- the services and deployments in kubernetes need to be able to listen to each other. you can accomplish this with a quick hack on localhost until I can make an appropriate setup that only exposes the web based UI through an ingress channel.

- NOTE: RUN THESE IN SEPARATE TERMINALS
```
kubectl port-forward service/godot-client 8080:80


kubectl port-forward service/godot-server 8082:80
```
