## Customize Makefile settings for HDRN
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile


# Use of --method subset for imports

$(IMPORTDIR)/%_import.owl: $(MIRRORDIR)/%.owl $(IMPORTDIR)/%_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/$*_terms_combined.txt --force true --copy-ontology-annotations true --method subset \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/inject-synonymtype-declaration.ru --update ../sparql/postprocess-module.ru \
		$(ANNOTATE_CONVERT_FILE); fi

# Custom reports exported in csv rather than tsv

SPARQL_CSTM_EXPORTS_ARGS = $(foreach V,$(SPARQL_EXPORTS),-s $(SPARQLDIR)/$(V).sparql $(REPORTDIR)/$(V).csv)

SPARQL_SBST_EXPORTS_ARGS = $(foreach V,$(SPARQL_EXPORTS),-s $(SPARQLDIR)/$(V).sparql $(REPORTDIR)/$(V)-subset.csv)

#SPARQL_SBST_EXPORTS_ARGS = $($(SPARQLDIR)/base-classes-report.sparql $(REPORTDIR)/HDRNv1-subset.csv)

.PHONY: custom_reports
custom_reports: $(EDIT_PREPROCESSED) | $(REPORTDIR)
ifneq ($(SPARQL_EXPORTS_ARGS),)
	$(ROBOT) query --use-graphs true -i $< $(SPARQL_CSTM_EXPORTS_ARGS)
endif

# Command for building doc without GitHub publish

build_docs:
	mkdocs build --config-file ../../mkdocs.yaml


# Command for sparql report on subset


#.PHONY: subset_reports
#subset_reports: $(EDIT_PREPROCESSED) | $(REPORTDIR)
#ifneq ($(SPARQL_EXPORTS_ARGS),)
#	$(ROBOT) query --use-graphs true -i $(SUBSETDIR)/HDRNv1.owl $(SPARQL_SBST_EXPORTS_ARGS)
#endif

subset_reports:
	$(ROBOT) query --use-graphs true -i $(SUBSETDIR)/HDRNv1.owl --query ../sparql/subset-report.sparql reports/subset-classes-report.csv
