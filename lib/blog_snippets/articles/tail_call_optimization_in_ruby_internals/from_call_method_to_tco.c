static void
vm_search_method(rb_call_info_t *ci, VALUE recv)
{
  VALUE klass = CLASS_OF(recv);

#if OPT_INLINE_METHOD_CACHE
  if (LIKELY(GET_GLOBAL_METHOD_STATE() == ci->method_state && RCLASS_SERIAL(klass) == ci->class_serial)) {
    /* cache hit! */
    return;
  }
#endif

  ci->me = rb_method_entry(klass, ci->mid, &ci->defined_class);
  ci->klass = klass;
  ci->call = vm_call_general;
#if OPT_INLINE_METHOD_CACHE
  ci->method_state = GET_GLOBAL_METHOD_STATE();
  ci->class_serial = RCLASS_SERIAL(klass);
#endif
}


static VALUE
vm_call_general(rb_thread_t *th, rb_control_frame_t *reg_cfp, rb_call_info_t *ci)
{
    return vm_call_method(th, reg_cfp, ci);
}


VALUE
vm_call_method(rb_thread_t *th, rb_control_frame_t *cfp, rb_call_info_t *ci)
{
  int enable_fastpath = 1;
  rb_call_info_t ci_temp;

start_method_dispatch:
  if (ci->me != 0) {
    if ((ci->me->flag == 0)) {
      VALUE klass;

normal_method_dispatch:
      switch (ci->me->def->type) {
        case VM_METHOD_TYPE_ISEQ:{
                                   CI_SET_FASTPATH(ci, vm_call_iseq_setup, enable_fastpath);
                                   return vm_call_iseq_setup(th, cfp, ci);
                                 }
        case VM_METHOD_TYPE_NOTIMPLEMENTED:
        case VM_METHOD_TYPE_CFUNC:
                                 CI_SET_FASTPATH(ci, vm_call_cfunc, enable_fastpath);
                                 return vm_call_cfunc(th, cfp, ci);
        case VM_METHOD_TYPE_ATTRSET:{
                                      CALLER_SETUP_ARG(cfp, ci);
                                      rb_check_arity(ci->argc, 1, 1);
                                      ci->aux.index = 0;
                                      CI_SET_FASTPATH(ci, vm_call_attrset, enable_fastpath && !(ci->flag & VM_CALL_ARGS_SPLAT));
                                      return vm_call_attrset(th, cfp, ci);
                                    }
        case VM_METHOD_TYPE_IVAR:{
                                   CALLER_SETUP_ARG(cfp, ci);
                                   rb_check_arity(ci->argc, 0, 0);
                                   ci->aux.index = 0;
                                   CI_SET_FASTPATH(ci, vm_call_ivar, enable_fastpath && !(ci->flag & VM_CALL_ARGS_SPLAT));
                                   return vm_call_ivar(th, cfp, ci);
                                 }
        case VM_METHOD_TYPE_MISSING:{
                                      ci->aux.missing_reason = 0;
                                      CI_SET_FASTPATH(ci, vm_call_method_missing, enable_fastpath);
                                      return vm_call_method_missing(th, cfp, ci);
                                    }
        case VM_METHOD_TYPE_BMETHOD:{
                                      CI_SET_FASTPATH(ci, vm_call_bmethod, enable_fastpath);
                                      return vm_call_bmethod(th, cfp, ci);
                                    }
        case VM_METHOD_TYPE_ZSUPER:{
                                     klass = ci->me->klass;
                                     klass = RCLASS_ORIGIN(klass);
zsuper_method_dispatch:
                                     klass = RCLASS_SUPER(klass);
                                     if (!klass) {
                                       ci->me = 0;
                                       goto start_method_dispatch;
                                     }
                                     ci_temp = *ci;
                                     ci = &ci_temp;

                                     ci->me = rb_method_entry(klass, ci->mid, &ci->defined_class);

                                     if (ci->me != 0) {
                                       goto normal_method_dispatch;
                                     }
                                     else {
                                       goto start_method_dispatch;
                                     }
                                   }
        case VM_METHOD_TYPE_OPTIMIZED:{
                                        switch (ci->me->def->body.optimize_type) {
                                          case OPTIMIZED_METHOD_TYPE_SEND:
                                            CI_SET_FASTPATH(ci, vm_call_opt_send, enable_fastpath);
                                            return vm_call_opt_send(th, cfp, ci);
                                          case OPTIMIZED_METHOD_TYPE_CALL:
                                            CI_SET_FASTPATH(ci, vm_call_opt_call, enable_fastpath);
                                            return vm_call_opt_call(th, cfp, ci);
                                          default:
                                            rb_bug("vm_call_method: unsupported optimized method type (%d)",
                                                ci->me->def->body.optimize_type);
                                        }
                                        break;
                                      }
        case VM_METHOD_TYPE_UNDEF:
                                      break;
        case VM_METHOD_TYPE_REFINED:{
                                      NODE *cref = rb_vm_get_cref(cfp->iseq, cfp->ep);
                                      VALUE refinements = cref ? cref->nd_refinements : Qnil;
                                      VALUE refinement, defined_class;
                                      rb_method_entry_t *me;

                                      refinement = find_refinement(refinements,
                                          ci->defined_class);
                                      if (NIL_P(refinement)) {
                                        goto no_refinement_dispatch;
                                      }
                                      me = rb_method_entry(refinement, ci->mid, &defined_class);
                                      if (me) {
                                        if (ci->call == vm_call_super_method) {
                                          rb_control_frame_t *top_cfp = current_method_entry(th, cfp);
                                          if (top_cfp->me &&
                                              rb_method_definition_eq(me->def, top_cfp->me->def)) {
                                            goto no_refinement_dispatch;
                                          }
                                        }
                                        ci->me = me;
                                        ci->defined_class = defined_class;
                                        if (me->def->type != VM_METHOD_TYPE_REFINED) {
                                          goto start_method_dispatch;
                                        }
                                      }

no_refinement_dispatch:
                                      if (ci->me->def->body.orig_me) {
                                        ci->me = ci->me->def->body.orig_me;
                                        if (UNDEFINED_METHOD_ENTRY_P(ci->me)) {
                                          ci->me = 0;
                                        }
                                        goto start_method_dispatch;
                                      }
                                      else {
                                        klass = ci->me->klass;
                                        goto zsuper_method_dispatch;
                                      }
                                    }
      }
      rb_bug("vm_call_method: unsupported method type (%d)", ci->me->def->type);
    }
    else {
      int noex_safe;
      if (!(ci->flag & VM_CALL_FCALL) && (ci->me->flag & NOEX_MASK) & NOEX_PRIVATE) {
        int stat = NOEX_PRIVATE;

        if (ci->flag & VM_CALL_VCALL) {
          stat |= NOEX_VCALL;
        }
        ci->aux.missing_reason = stat;
        CI_SET_FASTPATH(ci, vm_call_method_missing, 1);
        return vm_call_method_missing(th, cfp, ci);
      }
      else if (!(ci->flag & VM_CALL_OPT_SEND) && (ci->me->flag & NOEX_MASK) & NOEX_PROTECTED) {
        enable_fastpath = 0;
        if (!rb_obj_is_kind_of(cfp->self, ci->defined_class)) {
          ci->aux.missing_reason = NOEX_PROTECTED;
          return vm_call_method_missing(th, cfp, ci);
        }
        else {
          goto normal_method_dispatch;
        }
      }
      else if ((noex_safe = NOEX_SAFE(ci->me->flag)) > th->safe_level && (noex_safe > 2)) {
        rb_raise(rb_eSecurityError, "calling insecure method: %"PRIsVALUE, rb_id2str(ci->mid));
      }
      else {
        goto normal_method_dispatch;
      }
    }
  }
  else {
    /* method missing */
    int stat = 0;
    if (ci->flag & VM_CALL_VCALL) {
      stat |= NOEX_VCALL;
    }
    if (ci->flag & VM_CALL_SUPER) {
      stat |= NOEX_SUPER;
    }
    if (ci->mid == idMethodMissing) {
      rb_control_frame_t *reg_cfp = cfp;
      VALUE *argv = STACK_ADDR_FROM_TOP(ci->argc);
      rb_raise_method_missing(th, ci->argc, argv, ci->recv, stat);
    }
    else {
      ci->aux.missing_reason = stat;
      CI_SET_FASTPATH(ci, vm_call_method_missing, 1);
      return vm_call_method_missing(th, cfp, ci);
    }
  }

  rb_bug("vm_call_method: unreachable");
}


static VALUE
vm_call_iseq_setup(rb_thread_t *th, rb_control_frame_t *cfp, rb_call_info_t *ci)
{
  vm_callee_setup_arg(th, ci, ci->me->def->body.iseq, cfp->sp - ci->argc);
  return vm_call_iseq_setup_2(th, cfp, ci);
}


static VALUE
vm_call_iseq_setup_2(rb_thread_t *th, rb_control_frame_t *cfp, rb_call_info_t *ci)
{
  if (LIKELY(!(ci->flag & VM_CALL_TAILCALL))) {
    return vm_call_iseq_setup_normal(th, cfp, ci);
  }
  else {
    return vm_call_iseq_setup_tailcall(th, cfp, ci);
  }
}


static inline VALUE
vm_call_iseq_setup_normal(rb_thread_t *th, rb_control_frame_t *cfp, rb_call_info_t *ci)
{
  int i, local_size;
  VALUE *argv = cfp->sp - ci->argc;
  rb_iseq_t *iseq = ci->me->def->body.iseq;
  VALUE *sp = argv + iseq->param.size;

  /* clear local variables (arg_size...local_size) */
  for (i = iseq->param.size, local_size = iseq->local_size; i < local_size; i++) {
    *sp++ = Qnil;
  }

  vm_push_frame(th, iseq, VM_FRAME_MAGIC_METHOD, ci->recv, ci->defined_class,
      VM_ENVVAL_BLOCK_PTR(ci->blockptr),
      iseq->iseq_encoded + ci->aux.opt_pc, sp, 0, ci->me, iseq->stack_max);

  cfp->sp = argv - 1 /* recv */;
  return Qundef;
}


static inline VALUE
vm_call_iseq_setup_tailcall(rb_thread_t *th, rb_control_frame_t *cfp, rb_call_info_t *ci)
{
  int i;
  VALUE *argv = cfp->sp - ci->argc;
  rb_iseq_t *iseq = ci->me->def->body.iseq;
  VALUE *src_argv = argv;
  VALUE *sp_orig, *sp;
  VALUE finish_flag = VM_FRAME_TYPE_FINISH_P(cfp) ? VM_FRAME_FLAG_FINISH : 0;

  cfp = th->cfp = RUBY_VM_PREVIOUS_CONTROL_FRAME(th->cfp); /* pop cf */

  RUBY_VM_CHECK_INTS(th);

  sp_orig = sp = cfp->sp;

  /* push self */
  sp[0] = ci->recv;
  sp++;

  /* copy arguments */
  for (i=0; i < iseq->param.size; i++) {
    *sp++ = src_argv[i];
  }

  /* clear local variables */
  for (i = 0; i < iseq->local_size - iseq->param.size; i++) {
    *sp++ = Qnil;
  }

  vm_push_frame(th, iseq, VM_FRAME_MAGIC_METHOD | finish_flag,
    ci->recv, ci->defined_class, VM_ENVVAL_BLOCK_PTR(ci->blockptr),
    iseq->iseq_encoded + ci->aux.opt_pc, sp, 0, ci->me, iseq->stack_max);

  cfp->sp = sp_orig;
  return Qundef;
}
