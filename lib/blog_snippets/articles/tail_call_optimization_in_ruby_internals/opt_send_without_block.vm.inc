INSN_ENTRY(opt_send_without_block){
  {
    VALUE val;
    CALL_INFO ci = (CALL_INFO)GET_OPERAND(1);

    DEBUG_ENTER_INSN("opt_send_without_block");
    ADD_PC(1+1);
    PREFETCH(GET_PC());
    #define CURRENT_INSN_opt_send_without_block 1
    #define INSN_IS_SC()     0
    #define INSN_LABEL(lab)  LABEL_opt_send_without_block_##lab
    #define LABEL_IS_SC(lab) LABEL_##lab##_##t
    COLLECT_USAGE_INSN(BIN(opt_send_without_block));
    COLLECT_USAGE_OPERAND(BIN(opt_send_without_block), 0, ci);
    {
      ci->argc = ci->orig_argc;
      vm_search_method(ci, ci->recv = TOPN(ci->argc));
      CALL_METHOD(ci);

      CHECK_VM_STACK_OVERFLOW_FOR_INSN(REG_CFP, 1);
      PUSH(val);
      #undef CURRENT_INSN_opt_send_without_block
      #undef INSN_IS_SC
      #undef INSN_LABEL
      #undef LABEL_IS_SC
      END_INSN(opt_send_without_block);
    }
  }
}
