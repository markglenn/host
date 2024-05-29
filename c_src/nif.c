#include "erl_nif.h"
#include <libvirt/libvirt.h>

ERL_NIF_TERM sum(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    int a, b;
    enif_get_int(env, argv[0], &a);
    enif_get_int(env, argv[1], &b);
    return enif_make_int(env, a + b);
}

typedef struct
{
    virConnectPtr conn;
} virConnectResource;

static ErlNifResourceType *virConnectResourceType;

static void virConnectResource_dtor(ErlNifEnv *env, void *obj)
{
    virConnectResource *res = (virConnectResource *)obj;
    if (res->conn != NULL)
    {
        virConnectClose(res->conn);
    }
}

static ERL_NIF_TERM virConnectOpenNif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if (argc != 1)
    {
        return enif_make_badarg(env);
    }

    char uri[256];
    if (!enif_get_string(env, argv[0], uri, sizeof(uri), ERL_NIF_LATIN1))
    {
        return enif_make_badarg(env);
    }

    virConnectPtr conn = virConnectOpen(uri);

    if (conn == NULL)
    {
        return enif_make_atom(env, "error");
    }

    printf("Connected to hypervisor %s\n", virConnectGetType(conn));

    virConnectResource *res = enif_alloc_resource(virConnectResourceType, sizeof(virConnectResource));

    printf("Resource allocated\n");
    res->conn = conn;

    ERL_NIF_TERM term = enif_make_resource(env, res);
    enif_release_resource(res);

    return enif_make_tuple2(env, enif_make_atom(env, "ok"), term);
}

static ERL_NIF_TERM virConnectCloseNif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if (argc != 1)
    {
        return enif_make_badarg(env);
    }

    virConnectResource *res;
    if (!enif_get_resource(env, argv[0], virConnectResourceType, (void **)&res))
    {
        return enif_make_badarg(env);
    }

    virConnectClose(res->conn);

    return enif_make_atom(env, "ok");
}

static int load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info)
{
    const char *mod = "Elixir.Nif";
    const char *resource_type = "virConnectResource";

    virConnectResourceType = enif_open_resource_type(
        env, mod, resource_type, virConnectResource_dtor, ERL_NIF_RT_CREATE, NULL);

    if (virConnectResourceType == NULL)
    {
        return -1;
    }

    return 0;
}

static ErlNifFunc nif_funcs[] = {
    {"sum", 2, sum},
    {"vir_connect_open", 1, virConnectOpenNif},
    {"vir_connect_close", 1, virConnectCloseNif}};

ERL_NIF_INIT(Elixir.Nif, nif_funcs, load, NULL, NULL, NULL);